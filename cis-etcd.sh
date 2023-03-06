total_fail=$(kube-bench run --targets etcd --version 1.15 --check 2.2 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
    then
        echo "CIS Benchmark failed for etcd while testing for 2.2"
        exit 1;
    else
        echo "CIS Benchmark passed for etcd while testing 2.2"
fi;