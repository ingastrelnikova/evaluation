package authz

default allow = false

allow {

    # get metrics from Prometheus
    k_anonymity_response := http.send({
        "method": "GET",
        "url": "http://prometheus:9090/api/v1/query?query=k_anonymity"
    })

    k_anonymity_fluctuation_rate_response := http.send({
        "method": "GET",
        "url": "http://prometheus:9090/api/v1/query?query=k_anonymity_fluctuation_rate"
    })

    max_deletions_to_degrade_response := http.send({
        "method": "GET",
        "url": "http://prometheus:9090/api/v1/query?query=max_deletions_to_degrade"
    })

    k_anonymity_value := to_number(k_anonymity_response.body.data.result[0].value[1])
    k_anonymity_fluctuation_rate_value := to_number(k_anonymity_fluctuation_rate_response.body.data.result[0].value[1])
    max_deletions_to_degrade_value := to_number(max_deletions_to_degrade_response.body.data.result[0].value[1])

    # set policies
    k_anonymity_value >= 3
    k_anonymity_fluctuation_rate_value <=50
    max_deletions_to_degrade_value >=2
}
