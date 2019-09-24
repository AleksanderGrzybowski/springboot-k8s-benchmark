#!/usr/bin/env ruby 

#
# This is terrible Ruby. It's still better than the same in Bash :P
#

DEPLOY_RETRIES=60
REPORT_FILE='report.txt'
POD_BASENAME='spring'
BASE_ENDPOINT='http://localhost:31888'

def extract_ab_result(results, name) 
    lines = results.select { |e| e.start_with?(name) }
    return lines.empty? ? "(n/a)" : lines[0].split(":")[1].strip
end

def run_single_test(java_opts)
    puts "Deleting previous deployment if needed..."
    `kubectl delete -f all.yaml 2>&1`

    while true
        old_pod_count = `kubectl get pods | grep spring`.split("\n").size
        puts "Waiting until no pods present, currently #{old_pod_count} still up..."
        if old_pod_count == 0
            break
        end
        sleep 1
    end

    
    puts "Deploying application with JAVA_OPTS=#{java_opts}..."
    `JAVA_OPTS=#{java_opts} envsubst < all.yaml | kubectl apply -f -`

    deploy_success = false
    (1..DEPLOY_RETRIES).each { |i|
        pod_info = `kubectl get pods | grep #{POD_BASENAME}`.split(" ")   
        ready = pod_info[1]
        status = pod_info[2]

        puts "Waiting for '1/1 Running', currently '#{ready} #{status}' (try #{i}/#{DEPLOY_RETRIES})..."

        if ready == "1/1" && status == "Running"
            deploy_success = true
            break
        end
        sleep 1
    }

    if !deploy_success
        puts "No healthy pods, deployment failed."
        File.write(REPORT_FILE, "#{java_opts} DEPLOYMENT FAILED\n", mode: 'a')
        return
    end

    puts "Performing healthcheck..."
    `curl -fs #{BASE_ENDPOINT}/health`
    if $?.exitstatus != 0
        echo "Healthcheck failed."
        File.write(REPORT_FILE, "#{java_opts} HEALTHCHECK FAILED", mode: 'a')
        return
    end

    puts "Starting ab..."
    bench_result = `ab -c 1 -n 1000 #{BASE_ENDPOINT}/test`
    if $?.exitstatus != 0
        File.write(REPORT_FILE, "#{java_opts} BENCHMARK INIT FAILED", mode: 'a')
        echo "Benchmark start failed, failing"
        exit
    end

    arr = bench_result.split("\n")
    complete = extract_ab_result(arr, "Complete")
    failed = extract_ab_result(arr, "Failed")
    time_per_request = extract_ab_result(arr, "Time per request")
    non_20x = extract_ab_result(arr, "Non")

    puts "Complete: #{complete}, failed: #{failed}, non_20x: #{non_20x}, time per request: #{time_per_request}"
    File.write(REPORT_FILE, "#{java_opts} SUCCESS: Complete: #{complete}, failed: #{failed}, non_20x: #{non_20x}, time per request: #{time_per_request}\n", mode: 'a')

    puts "Deleting deployment..."
    `kubectl delete -f all.yaml 2>&1`
end

##############################################################

File.write(REPORT_FILE, "Report:\n")

run_single_test "-Xmx90m"
run_single_test "-Xmx80m"
run_single_test "-Xmx70m"

