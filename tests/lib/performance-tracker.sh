#!/bin/bash

# Performance Tracking and Monitoring System
# Provides detailed performance analysis and regression detection

# Configuration
readonly PERF_DATA_DIR="${TEST_REPORTS_DIR:-./test-reports}/performance"
readonly PERF_LOG_FILE="$PERF_DATA_DIR/performance.log"
readonly BENCHMARK_FILE="$PERF_DATA_DIR/benchmarks.json"

# Performance thresholds (in milliseconds)
readonly PERF_FAST_THRESHOLD=1000
readonly PERF_MODERATE_THRESHOLD=5000
readonly PERF_SLOW_THRESHOLD=10000
readonly PERF_REGRESSION_THRESHOLD=500

# Ensure performance data directory exists
ensure_perf_dir() {
    mkdir -p "$PERF_DATA_DIR"
}

# Start performance tracking for a test
start_performance_tracking() {
    local test_name="$1"
    local test_file="$2"
    
    ensure_perf_dir
    
    # Record start time with high precision
    local start_time
    start_time=$(date +%s%3N)  # milliseconds since epoch
    
    # Store in temporary tracking file
    echo "${test_name}|${test_file}|${start_time}" > "/tmp/perf_track_$$"
    
    echo "$start_time"
}

# End performance tracking and record results
end_performance_tracking() {
    local test_name="$1"
    local test_status="$2"
    local assertions_count="${3:-0}"
    
    local end_time
    end_time=$(date +%s%3N)
    
    # Read start time from temporary file
    local tracking_data
    if [ -f "/tmp/perf_track_$$" ]; then
        tracking_data=$(cat "/tmp/perf_track_$$")
        rm -f "/tmp/perf_track_$$"
    else
        echo "Warning: No performance tracking data found for $test_name" >&2
        return 1
    fi
    
    local tracked_name tracked_file start_time
    IFS='|' read -r tracked_name tracked_file start_time <<< "$tracking_data"
    
    local duration
    duration=$((end_time - start_time))
    
    # Log performance data
    local perf_entry
    perf_entry=$(cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "test_name": "$test_name",
    "test_file": "$tracked_file",
    "duration_ms": $duration,
    "status": "$test_status",
    "assertions_count": $assertions_count,
    "performance_class": "$(classify_performance "$duration")",
    "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
}
EOF
    )
    
    echo "$perf_entry" >> "$PERF_LOG_FILE"
    
    echo "$duration"
}

# Classify performance based on duration
classify_performance() {
    local duration="$1"
    
    if [ "$duration" -lt "$PERF_FAST_THRESHOLD" ]; then
        echo "fast"
    elif [ "$duration" -lt "$PERF_MODERATE_THRESHOLD" ]; then
        echo "moderate"
    elif [ "$duration" -lt "$PERF_SLOW_THRESHOLD" ]; then
        echo "slow"
    else
        echo "very_slow"
    fi
}

# Generate performance benchmark from historical data
generate_performance_benchmark() {
    ensure_perf_dir
    
    if [ ! -f "$PERF_LOG_FILE" ]; then
        echo "No performance data available for benchmarking"
        return 1
    fi
    
    # Analyze last 20 runs for each test
    local benchmark_data
    benchmark_data=$(tail -n 100 "$PERF_LOG_FILE" | jq -s '
        group_by(.test_name) | 
        map({
            test_name: .[0].test_name,
            test_file: .[0].test_file,
            runs_analyzed: length,
            performance_stats: {
                avg_duration_ms: (map(.duration_ms) | add / length),
                min_duration_ms: (map(.duration_ms) | min),
                max_duration_ms: (map(.duration_ms) | max),
                median_duration_ms: (map(.duration_ms) | sort | .[length/2]),
                std_deviation: (
                    map(.duration_ms) as $durations |
                    ($durations | add / length) as $mean |
                    ($durations | map(. - $mean | . * .) | add / length | sqrt)
                ),
                success_rate: (map(select(.status == "PASS")) | length) * 100 / length,
                performance_class: (map(.performance_class) | group_by(.) | map({class: .[0], count: length}) | sort_by(.count) | reverse | .[0].class)
            },
            recent_trend: (
                if length > 5 then
                    (.[length-3:] | map(.duration_ms) | add / 3) - 
                    (.[:3] | map(.duration_ms) | add / 3)
                else 0 end
            )
        })
    ')
    
    echo "$benchmark_data" > "$BENCHMARK_FILE"
    echo "$benchmark_data"
}

# Detect performance regressions
detect_performance_regressions() {
    local current_results=("$@")
    
    if [ ! -f "$BENCHMARK_FILE" ]; then
        echo "No benchmark data available for regression detection"
        return 1
    fi
    
    local regressions=()
    local improvements=()
    
    # Check each current result against benchmark
    for result in "${current_results[@]}"; do
        if [ -n "$result" ]; then
            local test_name duration
            test_name="$(echo "$result" | jq -r '.test_name')"
            duration="$(echo "$result" | jq -r '.duration')"
            
            # Get benchmark for this test
            local benchmark_avg
            benchmark_avg=$(jq -r --arg test "$test_name" '
                .[] | select(.test_name == $test) | .performance_stats.avg_duration_ms
            ' "$BENCHMARK_FILE")
            
            if [ "$benchmark_avg" != "null" ] && [ -n "$benchmark_avg" ]; then
                local difference
                difference=$(echo "$duration - $benchmark_avg" | bc -l)
                
                # Check for significant regression (>500ms slower)
                if (( $(echo "$difference > $PERF_REGRESSION_THRESHOLD" | bc -l) )); then
                    regressions+=("$test_name:$difference")
                # Check for significant improvement (>500ms faster)
                elif (( $(echo "$difference < -$PERF_REGRESSION_THRESHOLD" | bc -l) )); then
                    improvements+=("$test_name:$(echo "$difference * -1" | bc -l)")
                fi
            fi
        fi
    done
    
    # Generate regression report
    local regression_report
    regression_report=$(cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "analysis": {
        "regressions_detected": ${#regressions[@]},
        "improvements_detected": ${#improvements[@]},
        "threshold_ms": $PERF_REGRESSION_THRESHOLD
    },
    "regressions": [
EOF
    )
    
    # Add regression details
    local first=true
    for regression in "${regressions[@]}"; do
        local test_name difference
        IFS=':' read -r test_name difference <<< "$regression"
        
        if [ "$first" = true ]; then
            first=false
        else
            regression_report+=","
        fi
        
        regression_report+=$(cat <<EOF

        {
            "test_name": "$test_name",
            "performance_degradation_ms": $difference,
            "severity": "$(
                if (( $(echo "$difference > 2000" | bc -l) )); then echo "high"
                elif (( $(echo "$difference > 1000" | bc -l) )); then echo "medium"
                else echo "low"
                fi
            )"
        }
EOF
        )
    done
    
    regression_report+=$(cat <<EOF

    ],
    "improvements": [
EOF
    )
    
    # Add improvement details
    first=true
    for improvement in "${improvements[@]}"; do
        local test_name difference
        IFS=':' read -r test_name difference <<< "$improvement"
        
        if [ "$first" = true ]; then
            first=false
        else
            regression_report+=","
        fi
        
        regression_report+=$(cat <<EOF

        {
            "test_name": "$test_name",
            "performance_improvement_ms": $difference
        }
EOF
        )
    done
    
    regression_report+=$(cat <<EOF

    ]
}
EOF
    )
    
    echo "$regression_report"
}

# Generate performance summary report
generate_performance_summary() {
    local test_results=("$@")
    
    ensure_perf_dir
    
    local total_duration=0
    local test_count=0
    local slow_tests=0
    local fast_tests=0
    local performance_classes=()
    
    # Analyze current run performance
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local duration
            duration="$(echo "$result" | jq -r '.duration')"
            
            ((test_count++))
            total_duration=$((total_duration + duration))
            
            local perf_class
            perf_class=$(classify_performance "$duration")
            performance_classes+=("$perf_class")
            
            if [ "$perf_class" = "slow" ] || [ "$perf_class" = "very_slow" ]; then
                ((slow_tests++))
            elif [ "$perf_class" = "fast" ]; then
                ((fast_tests++))
            fi
        fi
    done
    
    local avg_duration
    if [ $test_count -gt 0 ]; then
        avg_duration=$(echo "scale=2; $total_duration / $test_count" | bc -l)
    else
        avg_duration="0"
    fi
    
    # Generate summary
    local summary
    summary=$(cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "performance_summary": {
        "total_tests": $test_count,
        "total_duration_ms": $total_duration,
        "avg_duration_ms": $avg_duration,
        "fast_tests": $fast_tests,
        "slow_tests": $slow_tests,
        "performance_score": $(echo "scale=2; ($fast_tests * 100) / $test_count" | bc -l 2>/dev/null || echo "0"),
        "classification": "$(classify_performance "$avg_duration")",
        "recommendations": [
EOF
    )
    
    # Add performance recommendations
    local recommendations=()
    
    if [ $slow_tests -gt 0 ]; then
        recommendations+=("\"Consider optimizing $slow_tests slow-running tests\"")
    fi
    
    if (( $(echo "$avg_duration > $PERF_MODERATE_THRESHOLD" | bc -l) )); then
        recommendations+=("\"Overall test suite performance needs improvement\"")
    fi
    
    if [ $test_count -gt 50 ] && (( $(echo "$total_duration > 60000" | bc -l) )); then
        recommendations+=("\"Consider parallel test execution to reduce total runtime\"")
    fi
    
    if [ ${#recommendations[@]} -eq 0 ]; then
        recommendations+=("\"Test performance is within acceptable limits\"")
    fi
    
    # Join recommendations
    local rec_string
    rec_string=$(IFS=','; echo "${recommendations[*]}")
    
    summary+="            $rec_string"
    summary+=$(cat <<EOF

        ]
    }
}
EOF
    )
    
    echo "$summary"
}

# Clean old performance data (keep last 200 entries)
cleanup_performance_data() {
    if [ -f "$PERF_LOG_FILE" ]; then
        local temp_file
        temp_file=$(mktemp)
        tail -n 200 "$PERF_LOG_FILE" > "$temp_file"
        mv "$temp_file" "$PERF_LOG_FILE"
    fi
}

# Export functions
export -f start_performance_tracking
export -f end_performance_tracking
export -f classify_performance
export -f generate_performance_benchmark
export -f detect_performance_regressions
export -f generate_performance_summary
export -f cleanup_performance_data