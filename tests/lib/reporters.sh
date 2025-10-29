#!/bin/bash

# Test Reporters for Multiple Output Formats
# Provides JSON, HTML, and console reporting capabilities

# Configuration
REPORTS_DIR="${TEST_REPORTS_DIR:-./test-reports}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
HISTORY_DIR="$REPORTS_DIR/history"
METRICS_FILE="$HISTORY_DIR/metrics.jsonl"
TRENDS_FILE="$HISTORY_DIR/trends.json"

# Colors for console output
REPORT_RED='\033[0;31m'
REPORT_GREEN='\033[0;32m'
REPORT_YELLOW='\033[1;33m'
REPORT_BLUE='\033[0;34m'
REPORT_CYAN='\033[0;36m'
REPORT_BOLD='\033[1m'
REPORT_NC='\033[0m' # No Color

# Ensure reports directory exists
ensure_reports_dir() {
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$HISTORY_DIR"
}

# Store metrics for historical tracking
store_metrics() {
    local test_results=("$@")
    
    ensure_reports_dir
    
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0
    local total_duration=0
    local slowest_test_duration=0
    local fastest_test_duration=999999
    local test_files=()
    
    # Calculate detailed metrics
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local status duration test_file
            status="$(echo "$result" | jq -r '.status')"
            duration="$(echo "$result" | jq -r '.duration')"
            test_file="$(echo "$result" | jq -r '.test_file')"
            
            ((total_tests++))
            total_duration=$((total_duration + duration))
            
            # Track performance metrics
            if [ "$duration" -gt "$slowest_test_duration" ]; then
                slowest_test_duration="$duration"
            fi
            if [ "$duration" -lt "$fastest_test_duration" ]; then
                fastest_test_duration="$duration"
            fi
            
            # Track unique test files
            if [[ ! " ${test_files[*]} " =~ " ${test_file} " ]]; then
                test_files+=("$test_file")
            fi
            
            case "$status" in
                "PASS") ((passed_tests++)) ;;
                "FAIL") ((failed_tests++)) ;;
                "SKIP") ((skipped_tests++)) ;;
            esac
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
    
    # Store metrics in JSONL format for historical tracking
    local metrics_entry
    metrics_entry=$(cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "run_id": "${TIMESTAMP}",
    "summary": {
        "total": $total_tests,
        "passed": $passed_tests,
        "failed": $failed_tests,
        "skipped": $skipped_tests,
        "success_rate": $success_rate,
        "total_duration_ms": $total_duration,
        "avg_duration_ms": $avg_duration,
        "slowest_test_ms": $slowest_test_duration,
        "fastest_test_ms": $fastest_test_duration,
        "test_files_count": ${#test_files[@]}
    },
    "environment": {
        "hostname": "$(hostname)",
        "user": "$(whoami)",
        "shell": "$SHELL",
        "parallel_jobs": "${TEST_PARALLEL_JOBS:-4}",
        "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
        "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')"
    }
}
EOF
    )
    
    echo "$metrics_entry" >> "$METRICS_FILE"
}

# Generate performance trends analysis
generate_trends_analysis() {
    if [ ! -f "$METRICS_FILE" ]; then
        echo "No historical data available for trends analysis"
        return 1
    fi
    
    # Get last 10 runs for trend analysis
    local recent_runs
    recent_runs=$(tail -n 10 "$METRICS_FILE")
    
    # Calculate trends
    local trend_data
    trend_data=$(echo "$recent_runs" | jq -s '
        {
            "analysis_timestamp": now | strftime("%Y-%m-%dT%H:%M:%SZ"),
            "runs_analyzed": length,
            "trends": {
                "success_rate": {
                    "current": (.[length-1].summary.success_rate // 0),
                    "average": (map(.summary.success_rate) | add / length),
                    "trend": (if length > 1 then 
                        (.[length-1].summary.success_rate - .[0].summary.success_rate) 
                        else 0 end)
                },
                "performance": {
                    "current_avg_duration": (.[length-1].summary.avg_duration_ms // 0),
                    "average_duration": (map(.summary.avg_duration_ms) | add / length),
                    "trend": (if length > 1 then 
                        (.[length-1].summary.avg_duration_ms - .[0].summary.avg_duration_ms) 
                        else 0 end)
                },
                "stability": {
                    "current_total": (.[length-1].summary.total // 0),
                    "average_total": (map(.summary.total) | add / length),
                    "failure_rate_trend": (if length > 1 then 
                        ((.[length-1].summary.failed / .[length-1].summary.total * 100) - 
                         (.[0].summary.failed / .[0].summary.total * 100))
                        else 0 end)
                }
            },
            "recent_runs": .
        }
    ')
    
    echo "$trend_data" > "$TRENDS_FILE"
    echo "$trend_data"
}

# Generate JSON report
generate_json_report() {
    local test_results=("$@")
    local output_file="$REPORTS_DIR/test-results-${TIMESTAMP}.json"
    
    ensure_reports_dir
    
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0
    local total_duration=0
    
    # Calculate detailed summary statistics
    local slowest_test_duration=0
    local fastest_test_duration=999999
    local test_suites=()
    local failed_assertions=0
    local total_assertions=0
    
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local status duration suite assertions
            status="$(echo "$result" | jq -r '.status')"
            duration="$(echo "$result" | jq -r '.duration')"
            suite="$(echo "$result" | jq -r '.suite // "unknown"')"
            
            # Track assertions if available
            local test_assertions
            test_assertions="$(echo "$result" | jq -r '.assertions.total // 0')"
            local test_failed_assertions
            test_failed_assertions="$(echo "$result" | jq -r '.assertions.failed // 0')"
            
            ((total_tests++))
            total_duration=$((total_duration + duration))
            total_assertions=$((total_assertions + test_assertions))
            failed_assertions=$((failed_assertions + test_failed_assertions))
            
            # Track performance metrics
            if [ "$duration" -gt "$slowest_test_duration" ]; then
                slowest_test_duration="$duration"
            fi
            if [ "$duration" -lt "$fastest_test_duration" ]; then
                fastest_test_duration="$duration"
            fi
            
            # Track unique test suites
            if [[ ! " ${test_suites[*]} " =~ " ${suite} " ]]; then
                test_suites+=("$suite")
            fi
            
            case "$status" in
                "PASS") ((passed_tests++)) ;;
                "FAIL") ((failed_tests++)) ;;
                "SKIP") ((skipped_tests++)) ;;
            esac
        fi
    done
    
    # Calculate additional metrics
    local success_rate avg_duration
    if [ $total_tests -gt 0 ]; then
        success_rate=$(echo "scale=2; $passed_tests * 100 / $total_tests" | bc -l)
        avg_duration=$(echo "scale=2; $total_duration / $total_tests" | bc -l)
    else
        success_rate="0"
        avg_duration="0"
    fi
    
    # Generate enhanced JSON structure
    cat > "$output_file" <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "run_id": "${TIMESTAMP}",
    "summary": {
        "total": $total_tests,
        "passed": $passed_tests,
        "failed": $failed_tests,
        "skipped": $skipped_tests,
        "success_rate": $success_rate,
        "total_duration_ms": $total_duration,
        "avg_duration_ms": $avg_duration,
        "slowest_test_ms": $slowest_test_duration,
        "fastest_test_ms": $fastest_test_duration,
        "test_suites_count": ${#test_suites[@]},
        "total_assertions": $total_assertions,
        "failed_assertions": $failed_assertions
    },
    "environment": {
        "hostname": "$(hostname)",
        "user": "$(whoami)",
        "pwd": "$(pwd)",
        "shell": "$SHELL",
        "parallel_jobs": "${TEST_PARALLEL_JOBS:-4}",
        "timeout": "${TEST_TIMEOUT:-60}",
        "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
        "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
        "system_info": {
            "os": "$(uname -s)",
            "arch": "$(uname -m)",
            "kernel": "$(uname -r)"
        }
    },
    "performance_metrics": {
        "tests_per_second": $(echo "scale=2; $total_tests * 1000 / $total_duration" | bc -l 2>/dev/null || echo "0"),
        "avg_assertions_per_test": $(echo "scale=2; $total_assertions / $total_tests" | bc -l 2>/dev/null || echo "0"),
        "performance_classification": "$(
            if [ "$avg_duration" -lt 1000 ]; then echo "fast"
            elif [ "$avg_duration" -lt 5000 ]; then echo "moderate"
            else echo "slow"
            fi
        )"
    },
    "tests": [
EOF
    
    # Add test results
    local first=true
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$output_file"
            fi
            echo "        $result" >> "$output_file"
        fi
    done
    
    cat >> "$output_file" <<EOF
    ]
}
EOF
    
    echo "$output_file"
}

# Generate HTML report
generate_html_report() {
    local test_results=("$@")
    local output_file="$REPORTS_DIR/test-results-${TIMESTAMP}.html"
    local json_file
    json_file="$(generate_json_report "${test_results[@]}")"
    
    ensure_reports_dir
    
    # Read summary from JSON
    local summary
    summary="$(jq '.summary' "$json_file")"
    local total
    total="$(echo "$summary" | jq -r '.total')"
    local passed
    passed="$(echo "$summary" | jq -r '.passed')"
    local failed
    failed="$(echo "$summary" | jq -r '.failed')"
    local skipped
    skipped="$(echo "$summary" | jq -r '.skipped')"
    local success_rate
    success_rate="$(echo "$summary" | jq -r '.success_rate')"
    local duration
    duration="$(echo "$summary" | jq -r '.total_duration_ms')"
    
    # Generate HTML
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Results - $(date)</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        .metric {
            text-align: center;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .metric-value {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .metric-label {
            color: #666;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .passed { color: #28a745; }
        .failed { color: #dc3545; }
        .skipped { color: #ffc107; }
        .total { color: #007bff; }
        .success-rate { color: #17a2b8; }
        .duration { color: #6f42c1; }
        .tests-table {
            margin: 0 30px 30px 30px;
        }
        .tests-table h2 {
            margin-bottom: 20px;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #333;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status.pass {
            background: #d4edda;
            color: #155724;
        }
        .status.fail {
            background: #f8d7da;
            color: #721c24;
        }
        .status.skip {
            background: #fff3cd;
            color: #856404;
        }
        .duration-cell {
            font-family: monospace;
            color: #666;
        }
        .progress-bar {
            width: 100%;
            height: 20px;
            background: #e9ecef;
            border-radius: 10px;
            overflow: hidden;
            margin: 20px 0;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #28a745, #20c997);
            transition: width 0.3s ease;
        }
        .charts-section {
            margin: 30px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .chart-title {
            font-size: 1.2em;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }
        .performance-insights {
            margin: 30px;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .insight-item {
            display: flex;
            align-items: center;
            margin: 10px 0;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 4px;
        }
        .insight-icon {
            margin-right: 10px;
            font-size: 1.2em;
        }
        .trend-indicator {
            display: inline-block;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 0.8em;
            font-weight: bold;
        }
        .trend-up { background: #d4edda; color: #155724; }
        .trend-down { background: #f8d7da; color: #721c24; }
        .trend-stable { background: #e2e3e5; color: #383d41; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Test Results</h1>
            <p>Generated on $(date)</p>
        </div>
        
        <div class="summary">
            <div class="metric">
                <div class="metric-value total">$total</div>
                <div class="metric-label">Total Tests</div>
            </div>
            <div class="metric">
                <div class="metric-value passed">$passed</div>
                <div class="metric-label">Passed</div>
            </div>
            <div class="metric">
                <div class="metric-value failed">$failed</div>
                <div class="metric-label">Failed</div>
            </div>
            <div class="metric">
                <div class="metric-value skipped">$skipped</div>
                <div class="metric-label">Skipped</div>
            </div>
            <div class="metric">
                <div class="metric-value success-rate">$success_rate%</div>
                <div class="metric-label">Success Rate</div>
            </div>
            <div class="metric">
                <div class="metric-value duration">$(echo "scale=2; $duration / 1000" | bc -l)s</div>
                <div class="metric-label">Total Duration</div>
            </div>
        </div>
        
        <div class="progress-bar">
            <div class="progress-fill" style="width: $success_rate%"></div>
        </div>
        
        <div class="charts-section">
            <div class="chart-container">
                <div class="chart-title">Test Results Distribution</div>
                <canvas id="resultsChart" width="400" height="200"></canvas>
            </div>
            <div class="chart-container">
                <div class="chart-title">Performance Overview</div>
                <canvas id="performanceChart" width="400" height="200"></canvas>
            </div>
        </div>
        
        <div class="performance-insights">
            <h2>Performance Insights</h2>
            <div class="insight-item">
                <span class="insight-icon">⚡</span>
                <span>Average test duration: $(echo "scale=2; $duration / $total / 1000" | bc -l)s per test</span>
            </div>
            <div class="insight-item">
                <span class="insight-icon">📊</span>
                <span>Tests per second: $(echo "scale=2; $total * 1000 / $duration" | bc -l)</span>
            </div>
            <div class="insight-item">
                <span class="insight-icon">🎯</span>
                <span>Success rate: $success_rate% ($([ $(echo "$success_rate >= 90" | bc -l) -eq 1 ] && echo "Excellent" || [ $(echo "$success_rate >= 75" | bc -l) -eq 1 ] && echo "Good" || echo "Needs Improvement"))</span>
            </div>
        </div>
        
        <div class="tests-table">
            <h2>Test Details</h2>
            <table>
                <thead>
                    <tr>
                        <th>Test Name</th>
                        <th>Status</th>
                        <th>Duration</th>
                        <th>File</th>
                    </tr>
                </thead>
                <tbody>
EOF
    
    # Add test rows
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local test_name
            test_name="$(echo "$result" | jq -r '.test_name')"
            local status
            status="$(echo "$result" | jq -r '.status')"
            local duration_ms
            duration_ms="$(echo "$result" | jq -r '.duration')"
            local test_file
            test_file="$(echo "$result" | jq -r '.test_file')"
            local duration_s
            duration_s="$(echo "scale=3; $duration_ms / 1000" | bc -l)"
            
            local status_class
            case "$status" in
                "PASS") status_class="pass" ;;
                "FAIL") status_class="fail" ;;
                "SKIP") status_class="skip" ;;
            esac
            
            cat >> "$output_file" <<EOF
                    <tr>
                        <td>$test_name</td>
                        <td><span class="status $status_class">$status</span></td>
                        <td class="duration-cell">${duration_s}s</td>
                        <td>$(basename "$test_file")</td>
                    </tr>
EOF
        fi
    done
    
    cat >> "$output_file" <<EOF
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        // Test Results Distribution Chart
        const resultsCtx = document.getElementById('resultsChart').getContext('2d');
        new Chart(resultsCtx, {
            type: 'doughnut',
            data: {
                labels: ['Passed', 'Failed', 'Skipped'],
                datasets: [{
                    data: [$passed, $failed, $skipped],
                    backgroundColor: ['#28a745', '#dc3545', '#ffc107'],
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
        
        // Performance Chart
        const performanceCtx = document.getElementById('performanceChart').getContext('2d');
        new Chart(performanceCtx, {
            type: 'bar',
            data: {
                labels: ['Total Duration', 'Avg per Test', 'Success Rate'],
                datasets: [{
                    label: 'Metrics',
                    data: [
                        $(echo "scale=2; $duration / 1000" | bc -l),
                        $(echo "scale=2; $duration / $total / 1000" | bc -l),
                        $success_rate
                    ],
                    backgroundColor: ['#007bff', '#17a2b8', '#28a745'],
                    borderColor: ['#0056b3', '#138496', '#1e7e34'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    </script>
</body>
</html>
EOF
    
    echo "$output_file"
}

# Generate console report with colors and formatting
generate_console_report() {
    local test_results=("$@")
    
    # Calculate summary
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0
    local total_duration=0
    local failed_test_names=()
    
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local status
            status="$(echo "$result" | jq -r '.status')"
            local duration
            duration="$(echo "$result" | jq -r '.duration')"
            local test_name
            test_name="$(echo "$result" | jq -r '.test_name')"
            
            ((total_tests++))
            total_duration=$((total_duration + duration))
            
            case "$status" in
                "PASS") ((passed_tests++)) ;;
                "FAIL") 
                    ((failed_tests++))
                    failed_test_names+=("$test_name")
                    ;;
                "SKIP") ((skipped_tests++)) ;;
            esac
        fi
    done
    
    local success_rate
    if [ $total_tests -gt 0 ]; then
        success_rate=$(echo "scale=1; $passed_tests * 100 / $total_tests" | bc -l)
    else
        success_rate="0"
    fi
    
    local duration_s
    duration_s=$(echo "scale=2; $total_duration / 1000" | bc -l)
    
    # Print formatted report
    echo ""
    printf "${REPORT_BOLD}${REPORT_BLUE}╔══════════════════════════════════════════════════════════════╗${REPORT_NC}\n"
    printf "${REPORT_BOLD}${REPORT_BLUE}║                        TEST RESULTS                          ║${REPORT_NC}\n"
    printf "${REPORT_BOLD}${REPORT_BLUE}╚══════════════════════════════════════════════════════════════╝${REPORT_NC}\n"
    echo ""
    
    # Summary metrics
    printf "${REPORT_BOLD}Summary:${REPORT_NC}\n"
    printf "  ${REPORT_CYAN}Total Tests:${REPORT_NC}    %d\n" "$total_tests"
    printf "  ${REPORT_GREEN}Passed:${REPORT_NC}        %d\n" "$passed_tests"
    printf "  ${REPORT_RED}Failed:${REPORT_NC}        %d\n" "$failed_tests"
    printf "  ${REPORT_YELLOW}Skipped:${REPORT_NC}       %d\n" "$skipped_tests"
    printf "  ${REPORT_CYAN}Success Rate:${REPORT_NC}  %s%%\n" "$success_rate"
    printf "  ${REPORT_CYAN}Duration:${REPORT_NC}      %ss\n" "$duration_s"
    echo ""
    
    # Progress bar
    local bar_width=50
    local filled_width
    filled_width=$(echo "scale=0; $success_rate * $bar_width / 100" | bc -l)
    local empty_width=$((bar_width - filled_width))
    
    printf "${REPORT_CYAN}Progress: ${REPORT_NC}["
    printf "${REPORT_GREEN}%*s${REPORT_NC}" "$filled_width" "" | tr ' ' '█'
    printf "%*s" "$empty_width" "" | tr ' ' '░'
    printf "] %s%%\n" "$success_rate"
    echo ""
    
    # Failed tests details
    if [ $failed_tests -gt 0 ]; then
        printf "${REPORT_RED}${REPORT_BOLD}Failed Tests:${REPORT_NC}\n"
        for test_name in "${failed_test_names[@]}"; do
            printf "  ${REPORT_RED}✗${REPORT_NC} %s\n" "$test_name"
        done
        echo ""
    fi
    
    # Performance insights and recommendations
    if [ $total_tests -gt 0 ]; then
        local avg_duration tests_per_second
        avg_duration=$(echo "scale=2; $total_duration / $total_tests / 1000" | bc -l)
        tests_per_second=$(echo "scale=2; $total_tests * 1000 / $total_duration" | bc -l)
        
        printf "${REPORT_CYAN}${REPORT_BOLD}Performance Analysis:${REPORT_NC}\n"
        printf "  ${REPORT_CYAN}Average Duration:${REPORT_NC}  %ss per test\n" "$avg_duration"
        printf "  ${REPORT_CYAN}Throughput:${REPORT_NC}       %s tests/second\n" "$tests_per_second"
        printf "  ${REPORT_CYAN}Total Runtime:${REPORT_NC}    %ss\n" "$duration_s"
        
        # Performance classification and recommendations
        if (( $(echo "$avg_duration < 1" | bc -l) )); then
            printf "  ${REPORT_GREEN}✓ Excellent performance${REPORT_NC}\n"
        elif (( $(echo "$avg_duration < 3" | bc -l) )); then
            printf "  ${REPORT_YELLOW}⚡ Good performance${REPORT_NC}\n"
        elif (( $(echo "$avg_duration < 10" | bc -l) )); then
            printf "  ${REPORT_YELLOW}⚠ Moderate performance - consider optimization${REPORT_NC}\n"
        else
            printf "  ${REPORT_RED}⚠ Slow performance - optimization recommended${REPORT_NC}\n"
        fi
        
        # Additional insights
        if [ $failed_tests -eq 0 ] && (( $(echo "$success_rate == 100" | bc -l) )); then
            printf "  ${REPORT_GREEN}🎯 Perfect test run!${REPORT_NC}\n"
        elif (( $(echo "$success_rate >= 95" | bc -l) )); then
            printf "  ${REPORT_GREEN}✨ Excellent stability${REPORT_NC}\n"
        elif (( $(echo "$success_rate >= 80" | bc -l) )); then
            printf "  ${REPORT_YELLOW}📈 Good stability${REPORT_NC}\n"
        else
            printf "  ${REPORT_RED}🔧 Stability needs attention${REPORT_NC}\n"
        fi
        echo ""
    fi
    
    return $failed_tests
}

# Generate all report formats with historical tracking
generate_all_reports() {
    local test_results=("$@")
    
    echo "Generating comprehensive test reports..."
    
    # Store metrics for historical tracking
    store_metrics "${test_results[@]}"
    printf "  ${REPORT_GREEN}✓${REPORT_NC} Metrics stored for historical tracking\n"
    
    # Generate trend analysis
    local trends_output
    trends_output="$(generate_trends_analysis 2>/dev/null)"
    if [ $? -eq 0 ]; then
        printf "  ${REPORT_GREEN}✓${REPORT_NC} Trends analysis updated\n"
    fi
    
    local json_file
    json_file="$(generate_json_report "${test_results[@]}")"
    printf "  ${REPORT_GREEN}✓${REPORT_NC} JSON report: %s\n" "$json_file"
    
    local html_file
    html_file="$(generate_html_report "${test_results[@]}")"
    printf "  ${REPORT_GREEN}✓${REPORT_NC} HTML report: %s\n" "$html_file"
    
    echo ""
    generate_console_report "${test_results[@]}"
    
    # Show trend insights if available
    if [ -n "$trends_output" ]; then
        echo ""
        show_trend_insights "$trends_output"
    fi
}

# Show trend insights in console
show_trend_insights() {
    local trends_data="$1"
    
    printf "${REPORT_BOLD}${REPORT_CYAN}📈 Trend Analysis:${REPORT_NC}\n"
    
    local success_trend performance_trend
    success_trend="$(echo "$trends_data" | jq -r '.trends.success_rate.trend')"
    performance_trend="$(echo "$trends_data" | jq -r '.trends.performance.trend')"
    
    # Success rate trend
    if (( $(echo "$success_trend > 5" | bc -l) )); then
        printf "  ${REPORT_GREEN}📈 Success rate improving (+%.1f%%)${REPORT_NC}\n" "$success_trend"
    elif (( $(echo "$success_trend < -5" | bc -l) )); then
        printf "  ${REPORT_RED}📉 Success rate declining (%.1f%%)${REPORT_NC}\n" "$success_trend"
    else
        printf "  ${REPORT_CYAN}➡️  Success rate stable (%.1f%%)${REPORT_NC}\n" "$success_trend"
    fi
    
    # Performance trend
    if (( $(echo "$performance_trend < -100" | bc -l) )); then
        printf "  ${REPORT_GREEN}⚡ Performance improving (%.0fms faster)${REPORT_NC}\n" "$(echo "$performance_trend * -1" | bc -l)"
    elif (( $(echo "$performance_trend > 100" | bc -l) )); then
        printf "  ${REPORT_YELLOW}🐌 Performance declining (+%.0fms slower)${REPORT_NC}\n" "$performance_trend"
    else
        printf "  ${REPORT_CYAN}➡️  Performance stable${REPORT_NC}\n"
    fi
    
    local runs_analyzed
    runs_analyzed="$(echo "$trends_data" | jq -r '.runs_analyzed')"
    printf "  ${REPORT_CYAN}📊 Based on last %d test runs${REPORT_NC}\n" "$runs_analyzed"
    echo ""
}

# Generate CI/CD friendly output
generate_ci_report() {
    local test_results=("$@")
    local format="${1:-github}"  # github, gitlab, jenkins
    
    case "$format" in
        "github")
            generate_github_actions_report "${test_results[@]}"
            ;;
        "gitlab")
            generate_gitlab_ci_report "${test_results[@]}"
            ;;
        "jenkins")
            generate_jenkins_report "${test_results[@]}"
            ;;
        *)
            echo "Unknown CI format: $format" >&2
            return 1
            ;;
    esac
}

# GitHub Actions specific output
generate_github_actions_report() {
    local test_results=("$@")
    
    # Calculate summary
    local total_tests=0
    local failed_tests=0
    
    for result in "${test_results[@]}"; do
        if [ -n "$result" ]; then
            local status
            status="$(echo "$result" | jq -r '.status')"
            ((total_tests++))
            
            if [ "$status" = "FAIL" ]; then
                ((failed_tests++))
                local test_name
                test_name="$(echo "$result" | jq -r '.test_name')"
                local test_file
                test_file="$(echo "$result" | jq -r '.test_file')"
                
                echo "::error file=$test_file::Test failed: $test_name"
            fi
        fi
    done
    
    if [ $failed_tests -eq 0 ]; then
        echo "::notice::All $total_tests tests passed!"
    else
        echo "::warning::$failed_tests out of $total_tests tests failed"
    fi
}

# Generate performance regression report
generate_performance_regression_report() {
    local current_results=("$@")
    
    if [ ! -f "$METRICS_FILE" ]; then
        echo "No historical data available for regression analysis"
        return 1
    fi
    
    # Get baseline (average of last 5 runs, excluding current)
    local baseline_data
    baseline_data=$(tail -n 6 "$METRICS_FILE" | head -n 5 | jq -s '
        {
            "avg_duration": (map(.summary.avg_duration_ms) | add / length),
            "avg_success_rate": (map(.summary.success_rate) | add / length),
            "avg_total_tests": (map(.summary.total) | add / length)
        }
    ')
    
    # Calculate current metrics
    local current_total=0 current_duration=0 current_passed=0
    for result in "${current_results[@]}"; do
        if [ -n "$result" ]; then
            local duration status
            duration="$(echo "$result" | jq -r '.duration')"
            status="$(echo "$result" | jq -r '.status')"
            
            ((current_total++))
            current_duration=$((current_duration + duration))
            [ "$status" = "PASS" ] && ((current_passed++))
        fi
    done
    
    local current_avg_duration current_success_rate
    if [ $current_total -gt 0 ]; then
        current_avg_duration=$(echo "scale=2; $current_duration / $current_total" | bc -l)
        current_success_rate=$(echo "scale=2; $current_passed * 100 / $current_total" | bc -l)
    else
        current_avg_duration="0"
        current_success_rate="0"
    fi
    
    # Compare with baseline
    local baseline_avg_duration baseline_success_rate
    baseline_avg_duration="$(echo "$baseline_data" | jq -r '.avg_duration')"
    baseline_success_rate="$(echo "$baseline_data" | jq -r '.avg_success_rate')"
    
    local duration_change success_change
    duration_change=$(echo "scale=2; $current_avg_duration - $baseline_avg_duration" | bc -l)
    success_change=$(echo "scale=2; $current_success_rate - $baseline_success_rate" | bc -l)
    
    # Generate regression report
    local regression_file="$REPORTS_DIR/regression-${TIMESTAMP}.json"
    cat > "$regression_file" <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "regression_analysis": {
        "baseline": {
            "avg_duration_ms": $baseline_avg_duration,
            "success_rate": $baseline_success_rate,
            "runs_analyzed": 5
        },
        "current": {
            "avg_duration_ms": $current_avg_duration,
            "success_rate": $current_success_rate,
            "total_tests": $current_total
        },
        "changes": {
            "duration_change_ms": $duration_change,
            "success_rate_change": $success_change,
            "performance_regression": $(echo "$duration_change > 500" | bc -l),
            "quality_regression": $(echo "$success_change < -5" | bc -l)
        },
        "alerts": [
EOF
    
    # Add alerts for significant regressions
    local alerts_added=false
    
    if (( $(echo "$duration_change > 1000" | bc -l) )); then
        [ "$alerts_added" = true ] && echo "," >> "$regression_file"
        echo '            {"type": "performance", "severity": "high", "message": "Significant performance regression detected (>1s slower)"}' >> "$regression_file"
        alerts_added=true
    elif (( $(echo "$duration_change > 500" | bc -l) )); then
        [ "$alerts_added" = true ] && echo "," >> "$regression_file"
        echo '            {"type": "performance", "severity": "medium", "message": "Performance regression detected (>500ms slower)"}' >> "$regression_file"
        alerts_added=true
    fi
    
    if (( $(echo "$success_change < -10" | bc -l) )); then
        [ "$alerts_added" = true ] && echo "," >> "$regression_file"
        echo '            {"type": "quality", "severity": "high", "message": "Significant quality regression detected (>10% success rate drop)"}' >> "$regression_file"
        alerts_added=true
    elif (( $(echo "$success_change < -5" | bc -l) )); then
        [ "$alerts_added" = true ] && echo "," >> "$regression_file"
        echo '            {"type": "quality", "severity": "medium", "message": "Quality regression detected (>5% success rate drop)"}' >> "$regression_file"
        alerts_added=true
    fi
    
    cat >> "$regression_file" <<EOF
        ]
    }
}
EOF
    
    echo "$regression_file"
}

# Clean old historical data (keep last 50 runs)
cleanup_historical_data() {
    if [ -f "$METRICS_FILE" ]; then
        local temp_file
        temp_file=$(mktemp)
        tail -n 50 "$METRICS_FILE" > "$temp_file"
        mv "$temp_file" "$METRICS_FILE"
    fi
}

# Export functions for use in other scripts
export -f generate_json_report
export -f generate_html_report  
export -f generate_console_report
export -f generate_all_reports
export -f generate_ci_report
export -f store_metrics
export -f generate_trends_analysis
export -f generate_performance_regression_report
export -f cleanup_historical_data