## Scenario 4: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact
![scenario4.png](../../assets/scenario4.png)

Refer to the tutorial [README.md](../../deployments/scenario4/README.md) to provision the VMs, then you can follow the tutorial below.

Ensure that the networks are able to reach each other (from virbr1 to virbr2 and vice-versa). Ensure that all VMs are able to reach internet. You might want to add extra iptables rules to masquerade the network:
```bash
iptables -t nat -A POSTROUTING -s <your network ip subnet> -j MASQUERADE
```

Then run the script to deploy the Prometheus with Thanos with Thanos Store Gateway, Thanos Compact and Grafana Environment:
```bash
bash deploy.sh
```

When needs to cleanup the environment, run this script:
```bash
bash cleanup.sh
```
