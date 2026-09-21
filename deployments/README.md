The scenario is continued from scenario 1 until scenario 4. Be sure to do the provisioning from scenario 1 until scenario 4.

Ensure that you have the necessary virtual networks in your KVM environment.

virbr1, virbr2, and virbr3 are deployed with Routed Network.

By default, it will be able to reach each other network but cannot react the Host Network Services.

Apply the following firewalld rules for allowing to reach the Host Network Services:

```bash
firewall-cmd --policy libvirt-to-host --permanent --add-port=8000-10000/tcp
firewall-cmd --reload
```