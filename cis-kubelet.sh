total_fail=$(kube-bench run --targets node --version 1.15 --check 4.2.1,4.2.2 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
    then    
        echo "CIS Benchmark failed kubelet while testing for 4.2.1, 4.2.2"
        exit 1;
    else
        echo "CIS Benchmark passed Kubelet while testing 4.2.1, 4.2.2"    
fi;        