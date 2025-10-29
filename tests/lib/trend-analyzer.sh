#!/bin/bash

# Trend Analysis System
# Provides sophisticated trend detection and forecasting for test metrics

# Configuration
readonly TRENDS_DIR="${TEST_REPORTS_DIR:-./test-reports}/trends"
readonly TREND_DATA_FILE="$TRENDS_DIR/trend-data.jsonl"
readonly FORECAST_FILE="$TRENDS_DIR/forecast.json"

# Trend detection parameters
readonly TREND_WINDOW=10  # Number of runs to analyze for trends
readonly SIGNIFICANT_CHANGE_THRESHOLD=5  # Percentage change to consider significant

# Ensure trends directory exists
ensure_trends_dir() {
    mkdir -p "$TRENDS_DIR"
}

# Record trend data point
record_trend_data() {
    local test_results=("$@")
    
    ensure_trends_dir
    
    # Calculate metrics for this run
    local total_tests=0 passed_tests=0 failed_tests=0 total_duration=0
    local test_files=() unique_suites=()
    
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local status duration suite test_file
            status="$(echo "$result" | jq -r '.status')"
            duration="$(echo "$result" | jq -r '.duration')"
            suite="$(echo "$result" | jq -r '.suite // "unknown"')"
            test_file="$(echo "$result" | jq -r '.test_file')"
            
            ((total_tests++))
            total_duration=$((total_duration + duration))
            
            case "$status" in
                "PASS") ((passed_tests++)) ;;
                "FAIL") ((failed_tests++)) ;;
            esac
            
            # Track unique files and suites
            if [[ ! " ${test_files[*]} " =~ " ${test_file} " ]]; then
                test_files+=("$test_file")
            fi
            if [[ ! " ${unique_suites[*]} " =~ " ${suite} " ]]; then
                unique_suites+=("$suite")
            fi
        fi
    done
    
    local success_rate avg_duration
    if [ $total_tests -gt 0 ]; then
        success_rate=$(echo "scale=2; $passed_tests * 100 / $total_tests" | bc -l)
        avg_duration=$(echo "scale=2; $total_duration / $total_tests" | bc -l)
    else
        success_rate="0"
        avg_duration="0"
    fi
    
    # Create trend data entry
    local trend_entry
    trend_entry=$(cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "run_id": "$(date +%Y%m%d_%H%M%S)",
    "metrics": {
        "total_tests": $total_tests,
        "success_rate": $success_rate,
        "avg_duration_ms": $avg_duration,
        "total_duration_ms": $total_duration,
        "test_files_count": ${#test_files[@]},
        "test_suites_count": ${#unique_suites[@]},
        "failed_tests": $failed_tests
    },
    "environment": {
        "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
        "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
        "hostname": "$(hostname)"
    }
}
EOF
    )
    
    echo "$trend_entry" >> "$TREND_DATA_FILE"
}

# Analyze trends from historical data
analyze_trends() {
    ensure_trends_dir
    
    if [ ! -f "$TREND_DATA_FILE" ]; then
        echo "No trend data available for analysis"
        return 1
    fi
    
    # Get recent data for trend analysis
    local recent_data
    recent_data=$(tail -n "$TREND_WINDOW" "$TREND_DATA_FILE")
    
    if [ $(echo "$recent_data" | wc -l) -lt 3 ]; then
        echo "Insufficient data for trend analysis (need at least 3 runs)"
        return 1
    fi
    
    # Calculate trends using linear regression approximation
    local trend_analysis
    trend_analysis=$(echo "$recent_data" | jq -s '
        def linear_trend(values):
            if (values | length) < 2 then 0
            else
                (values | length) as $n |
                (values | keys | map(. + 1) | add / length) as $x_mean |
                (values | add / length) as $y_mean |
                (
                    [range($n) | . as $i | (($i + 1) - $x_mean) * (values[$i] - $y_mean)] | add
                ) / (
                    [range($n) | . as $i | (($i + 1) - $x_mean) * (($i + 1) - $x_mean)] | add
                )
            end;
        
        def trend_direction(slope; threshold):
            if slope > threshold then "improving"
            elif slope < -threshold then "declining" 
            else "stable"
            end;
        
        def calculate_volatility(values):
            if (values | length) < 2 then 0
            else
                (values | add / length) as $mean |
                (values | map(. - $mean | . * .) | add / length | sqrt)
            end;
        
        {
            "analysis_timestamp": now | strftime("%Y-%m-%dT%H:%M:%SZ"),
            "data_points": length,
            "time_span_hours": ((.[length-1].timestamp | fromdateiso8601) - (.[0].timestamp | fromdateiso8601)) / 3600,
            "trends": {
                "success_rate": {
                    "values": map(.metrics.success_rate),
                    "current": .[length-1].metrics.success_rate,
                    "average": (map(.metrics.success_rate) | add / length),
                    "slope": linear_trend(map(.metrics.success_rate)),
                    "direction": trend_direction(linear_trend(map(.metrics.success_rate)); 1),
                    "volatility": calculate_volatility(map(.metrics.success_rate)),
                    "min": (map(.metrics.success_rate) | min),
                    "max": (map(.metrics.success_rate) | max)
                },
                "performance": {
                    "values": map(.metrics.avg_duration_ms),
                    "current": .[length-1].metrics.avg_duration_ms,
                    "average": (map(.metrics.avg_duration_ms) | add / length),
                    "slope": linear_trend(map(.metrics.avg_duration_ms)),
                    "direction": trend_direction(-linear_trend(map(.metrics.avg_duration_ms)); 50),
                    "volatility": calculate_volatility(map(.metrics.avg_duration_ms)),
                    "min": (map(.metrics.avg_duration_ms) | min),
                    "max": (map(.metrics.avg_duration_ms) | max)
                },
                "test_coverage": {
                    "values": map(.metrics.total_tests),
                    "current": .[length-1].metrics.total_tests,
                    "average": (map(.metrics.total_tests) | add / length),
                    "slope": linear_trend(map(.metrics.total_tests)),
                    "direction": trend_direction(linear_trend(map(.metrics.total_tests)); 1),
                    "volatility": calculate_volatility(map(.metrics.total_tests))
                }
            },
            "insights": {
                "stability_score": (
                    100 - (
                        (calculate_volatility(map(.metrics.success_rate)) * 10) +
                        (calculate_volatility(map(.metrics.avg_duration_ms)) / 100)
                    )
                ),
                "performance_consistency": (
                    100 - (calculate_volatility(map(.metrics.avg_duration_ms)) / 100)
                ),
                "quality_trend": trend_direction(linear_trend(map(.metrics.success_rate)); 1)
            }
        }
    ')
    
    echo "$trend_analysis"
}

# Generate trend forecast
generate_trend_forecast() {
    local trend_analysis="$1"
    
    if [ -z "$trend_analysis" ]; then
        trend_analysis=$(analyze_trends)
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi
    
    # Generate forecast based on current trends
    local forecast
    forecast=$(echo "$trend_analysis" | jq '
        {
            "forecast_timestamp": now | strftime("%Y-%m-%dT%H:%M:%SZ"),
            "forecast_horizon": "next_5_runs",
            "predictions": {
                "success_rate": {
                    "current": .trends.success_rate.current,
                    "predicted_next": (.trends.success_rate.current + (.trends.success_rate.slope * 1)),
                    "predicted_5_runs": (.trends.success_rate.current + (.trends.success_rate.slope * 5)),
                    "confidence": (
                        if .trends.success_rate.volatility < 5 then "high"
                        elif .trends.success_rate.volatility < 15 then "medium"
                        else "low"
                        end
                    )
                },
                "performance": {
                    "current_avg_ms": .trends.performance.current,
                    "predicted_next_ms": (.trends.performance.current + (.trends.performance.slope * 1)),
                    "predicted_5_runs_ms": (.trends.performance.current + (.trends.performance.slope * 5)),
                    "confidence": (
                        if .trends.performance.volatility < 100 then "high"
                        elif .trends.performance.volatility < 500 then "medium"
                        else "low"
                        end
                    )
                }
            },
            "recommendations": [
                (if .trends.success_rate.direction == "declining" then
                    "Success rate is declining - investigate failing tests"
                else empty end),
                (if .trends.performance.direction == "declining" then
                    "Performance is degrading - consider optimization"
                else empty end),
                (if .insights.stability_score < 70 then
                    "Test results are unstable - improve test reliability"
                else empty end),
                (if .trends.performance.current > 5000 then
                    "Average test duration is high - consider performance improvements"
                else empty end)
            ],
            "alerts": [
                (if (.trends.success_rate.current < 80) then
                    {"type": "quality", "severity": "high", "message": "Success rate below 80%"}
                else empty end),
                (if (.trends.performance.current > 10000) then
                    {"type": "performance", "severity": "high", "message": "Average test duration exceeds 10 seconds"}
                else empty end),
                (if (.insights.stability_score < 50) then
                    {"type": "stability", "severity": "medium", "message": "Test results are highly unstable"}
                else empty end)
            ]
        }
    ')
    
    echo "$forecast" > "$FORECAST_FILE"
    echo "$forecast"
}

# Generate trend visualization data for charts
generate_trend_visualization_data() {
    ensure_trends_dir
    
    if [ ! -f "$TREND_DATA_FILE" ]; then
        echo "No trend data available for visualization"
        return 1
    fi
    
    # Get last 20 runs for visualization
    local viz_data
    viz_data=$(tail -n 20 "$TREND_DATA_FILE" | jq -s '
        {
            "chart_data": {
                "labels": map(.timestamp | fromdateiso8601 | strftime("%m/%d %H:%M")),
                "datasets": [
                    {
                        "label": "Success Rate (%)",
                        "data": map(.metrics.success_rate),
                        "borderColor": "#28a745",
                        "backgroundColor": "rgba(40, 167, 69, 0.1)",
                        "yAxisID": "percentage"
                    },
                    {
                        "label": "Avg Duration (s)",
                        "data": map(.metrics.avg_duration_ms / 1000),
                        "borderColor": "#007bff", 
                        "backgroundColor": "rgba(0, 123, 255, 0.1)",
                        "yAxisID": "duration"
                    },
                    {
                        "label": "Total Tests",
                        "data": map(.metrics.total_tests),
                        "borderColor": "#6f42c1",
                        "backgroundColor": "rgba(111, 66, 193, 0.1)",
                        "yAxisID": "count"
                    }
                ]
            },
            "chart_config": {
                "type": "line",
                "options": {
                    "responsive": true,
                    "scales": {
                        "percentage": {
                            "type": "linear",
                            "position": "left",
                            "min": 0,
                            "max": 100,
                            "title": { "display": true, "text": "Success Rate (%)" }
                        },
                        "duration": {
                            "type": "linear", 
                            "position": "right",
                            "title": { "display": true, "text": "Duration (s)" }
                        },
                        "count": {
                            "type": "linear",
                            "position": "right",
                            "title": { "display": true, "text": "Test Count" }
                        }
                    }
                }
            }
        }
    ')
    
    echo "$viz_data"
}

# Clean old trend data (keep last 100 entries)
cleanup_trend_data() {
    if [ -f "$TREND_DATA_FILE" ]; then
        local temp_file
        temp_file=$(mktemp)
        tail -n 100 "$TREND_DATA_FILE" > "$temp_file"
        mv "$temp_file" "$TREND_DATA_FILE"
    fi
}

# Export functions
export -f record_trend_data
export -f analyze_trends
export -f generate_trend_forecast
export -f generate_trend_visualization_data
export -f cleanup_trend_data