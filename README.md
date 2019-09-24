## Spring Boot heap benchmark

I was wondering, how little Java heap memory is required for barebones Spring Boot application to start and work properly. I'm a big fan of optimizing infrastructure costs, so I created a script, which will tell me *the truth*.

I assume we are running on either Minikube or the master node of the cluster, so we have access to local Docker daemon and we can use local images.  Script `docker-build.sh` will build Docker image `spring` using Java sources in `minimal-web` directory.  Script `run.rb` will prepare, deploy, test and benchmark this sample application. We are not concerned about the real performance, GC activity and such, we simply want to know, if it has a chance of working. After finishing, results can be found in `report.txt` file.



