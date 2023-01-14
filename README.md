# deploy-scripts
Scripts to help on deploying back-end projects to Digital Ocean.

To run the scripts, run the following commands in the droplet console:

```bash
bash -i <(curl -s https://raw.githubusercontent.com/polijrorg/deploy-scripts/main/scripts/1-root.sh)
```

```bash
bash -i <(curl -s https://raw.githubusercontent.com/polijrorg/deploy-scripts/main/scripts/2-clone-and-build.sh)
```

```bash
bash -i <(curl -s https://raw.githubusercontent.com/polijrorg/deploy-scripts/main/scripts/3-docker-and-prisma.sh)
```

```bash
bash -i <(curl -s https://raw.githubusercontent.com/polijrorg/deploy-scripts/main/scripts/4-nginx-and-pm2.sh)
```
