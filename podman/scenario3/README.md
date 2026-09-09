## Scenario 3: Applying Object Storage Data Retention with rustFS, Thanos Store Gateway, and Thanos Compact
![scenario3.png](../../assets/scenario3.png)

Refer to the tutorial [README.md](../../deployments/scenario3/README.md) to provision the VMs, then you can follow the tutorial below.

### Deploying the environment

Deploy the rustfs in your laptop to represent external datacenter in your environment. Feel free to change the access key and secret key there:
```bash
bash deploy-rustfs.sh
```

Ensure that all VMs are able to reach internet. You might want to add extra iptables rules to masquerade the network:
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