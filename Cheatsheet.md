## SSH with port forwarding

```
ssh-add ~/.ssh/id_rsa
```

then:
```
ssh -A -i ~/.ssh/id_rsa ubuntu@<Bastion-Public-IP>
```
