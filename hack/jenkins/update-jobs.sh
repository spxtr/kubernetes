#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Update all Jenkins jobs in a folder. If no folder is provided in $1,
# defaults to hack/jenkins/job-configs.

if [[ $# -eq 1 ]]; then
  config_dir=$1
else
  config_dir="hack/jenkins/job-configs"
fi

# Run the container if it isn't present.
if ! docker inspect job-builder > /dev/null; then
  docker run -idt \
    --net host \
    --name job-builder \
    --restart always \
    gcr.io/google_containers/kubekins-job-builder
  # jenkins_jobs.ini contains administrative credentials for Jenkins.
  # Store it in the workspace of the Jenkins job that calls this script.
  docker cp jenkins_jobs.ini job-builder:/etc/jenkins_jobs
fi

docker exec job-builder git pull
docker exec job-builder jenkins-jobs update ${config_dir}
