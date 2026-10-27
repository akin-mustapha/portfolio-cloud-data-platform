# README

```sh
python3 -m src.t212-dca
```

## Glosary

-

## Commands

**ECR Loging:**

```sh
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 861580917950.dkr.ecr.eu-west-1.amazonaws.com
```

```sh
docker build -t portfolio-dev/t212-automation .
```

```sh
docker tag portfolio-dev/t212-automation:latest 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest
```

```sh
docker push 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest
```

```sh
aws lambda update-function-code \
  --function-name portfolio-dev-dca \
  --image-uri 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest \
  --region eu-west-1
```

## Troubleshooting

**Encountered error while generating package metadata:**

```txt
 => CACHED [2/5] RUN python -m pip install --upgrade pip                                                                                  0.0s
 => CACHED [3/5] COPY requirements.txt /var/task/                                                                                         0.0s
 => ERROR [4/5] RUN pip3 install --user --no-cache-dir     -r /var/task/requirements.txt                                                  5.0s
------                                                                                                                                         
 > [4/5] RUN pip3 install --user --no-cache-dir     -r /var/task/requirements.txt:                                                             
0.478 Collecting requests (from -r /var/task/requirements.txt (line 1))                                                                        
0.514   Downloading requests-2.34.2-py3-none-any.whl.metadata (4.8 kB)                                                                         
0.591 Collecting pandas (from -r /var/task/requirements.txt (line 2))                                                                          
0.600   Downloading pandas-3.1.0-cp311-cp311-manylinux_2_24_aarch64.manylinux_2_28_aarch64.whl.metadata (18 kB)                                
0.609 Requirement already satisfied: boto3 in /var/lang/lib/python3.11/site-packages (from -r /var/task/requirements.txt (line 3)) (1.42.97)
0.609 Requirement already satisfied: botocore in /var/lang/lib/python3.11/site-packages (from -r /var/task/requirements.txt (line 4)) (1.42.97)
0.625 Collecting awswrangler (from -r /var/task/requirements.txt (line 6))
0.633   Downloading awswrangler-3.17.1-py3-none-any.whl.metadata (17 kB)
0.650 Collecting httpx (from -r /var/task/requirements.txt (line 7))
0.662   Downloading httpx-0.28.1-py3-none-any.whl.metadata (7.1 kB)
0.709 Collecting pydantic (from -r /var/task/requirements.txt (line 8))
0.717   Downloading pydantic-2.14.1-py3-none-any.whl.metadata (133 kB)
0.749 Collecting pydantic-settings (from -r /var/task/requirements.txt (line 9))
0.761   Downloading pydantic_settings-2.16.1-py3-none-any.whl.metadata (4.0 kB)
0.817 Collecting charset_normalizer<4,>=2 (from requests->-r /var/task/requirements.txt (line 1))
0.824   Downloading charset_normalizer-3.5.2-cp311-cp311-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl.metadata (46 kB)
0.842 Collecting idna<4,>=2.5 (from requests->-r /var/task/requirements.txt (line 1))
0.849   Downloading idna-3.20-py3-none-any.whl.metadata (7.2 kB)
0.850 Requirement already satisfied: urllib3<3,>=1.26 in /var/lang/lib/python3.11/site-packages (from requests->-r /var/task/requirements.txt (line 1)) (2.8.0)
0.868 Collecting certifi>=2023.5.7 (from requests->-r /var/task/requirements.txt (line 1))
0.877   Downloading certifi-2026.10.23-py3-none-any.whl.metadata (2.5 kB)
1.080 Collecting numpy>=2.0.2 (from pandas->-r /var/task/requirements.txt (line 2))
1.103   Downloading numpy-2.4.6.tar.gz (20.7 MB)
1.438      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 20.7/20.7 MB 63.5 MB/s  0:00:00
2.779   Installing build dependencies: started
3.752   Installing build dependencies: finished with status 'done'
3.753   Getting requirements to build wheel: started
3.815   Getting requirements to build wheel: finished with status 'done'
3.816   Installing backend dependencies: started
4.140   Installing backend dependencies: finished with status 'done'
4.141   Preparing metadata (pyproject.toml): started
4.601   Preparing metadata (pyproject.toml): finished with status 'error'
4.605   error: subprocess-exited-with-error
4.605   
4.605   × Preparing metadata (pyproject.toml) did not run successfully.
4.605   │ exit code: 1
4.605   ╰─> [20 lines of output]
4.605       + /var/lang/bin/python /tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc/vendored-meson/meson/meson.py setup /tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc /tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc/.mesonpy-da63es5t -Dbuildtype=release -Db_ndebug=if-release -Db_vscrt=md --native-file=/tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc/.mesonpy-da63es5t/meson-python-native-file.ini
4.605       The Meson build system
4.605       Version: 1.9.2
4.605       Source dir: /tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc
4.605       Build dir: /tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc/.mesonpy-da63es5t
4.605       Build type: native build
4.605       Project name: NumPy
4.605       Project version: 2.4.6
4.605       
4.605       ../meson.build:1:0: ERROR: Unknown compiler(s): [['cc'], ['gcc'], ['clang'], ['nvc'], ['pgcc'], ['icc'], ['icx']]
4.605       The following exception(s) were encountered:
4.605       Running `cc --version` gave "[Errno 2] No such file or directory: 'cc'"
4.605       Running `gcc --version` gave "[Errno 2] No such file or directory: 'gcc'"
4.605       Running `clang --version` gave "[Errno 2] No such file or directory: 'clang'"
4.605       Running `nvc --version` gave "[Errno 2] No such file or directory: 'nvc'"
4.605       Running `pgcc --version` gave "[Errno 2] No such file or directory: 'pgcc'"
4.605       Running `icc --version` gave "[Errno 2] No such file or directory: 'icc'"
4.605       Running `icx --version` gave "[Errno 2] No such file or directory: 'icx'"
4.605       
4.605       A full log can be found at /tmp/pip-install-q59gr27k/numpy_fabde56612c444b1b370a6bae9d3e2dc/.mesonpy-da63es5t/meson-logs/meson-log.txt
4.605       [end of output]
4.605   
4.605   note: This error originates from a subprocess, and is likely not a problem with pip.
4.606 error: metadata-generation-failed
4.606 
4.606 × Encountered error while generating package metadata.
4.606 ╰─> numpy
4.606 
4.606 note: This is an issue with the package mentioned above, not pip.
4.606 hint: See above for details.
------
Dockerfile:7
--------------------
   6 |     
   7 | >>> RUN pip3 install --user --no-cache-dir \
   8 | >>>     -r ${LAMBDA_TASK_ROOT}/requirements.txt
   9 |     
--------------------
ERROR: failed to build: failed to solve: process "/bin/sh -c pip3 install --user --no-cache-dir     -r ${LAMBDA_TASK_ROOT}/requirements.txt" did not complete successfully: exit code: 1

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/04j5gltqnpmoldowqfvo3052x
```

**Fix:**

Update python version from 3.11 to 3.12

```dockerfile
FROM public.ecr.aws/lambda/python:3.11
```

```dockerfile
FROM public.ecr.aws/lambda/python:3.12
```

## Container deployment compatibility

```txt
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.lambda_dca.aws_lambda_function.this: Creating...
╷
│ Error: creating Lambda Function (portfolio-dev-dca): operation error Lambda: CreateFunction, https response error StatusCode: 400, RequestID: cf7e99e6-708a-4fd1-81af-38b8cdf96988, InvalidParameterValueException: The image manifest, config or layer media type for the source image 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest is not supported.
│ 
│   with module.lambda_dca.aws_lambda_function.this,
│   on modules/lambda_function/main.tf line 11, in resource "aws_lambda_function" "this":
│   11: resource "aws_lambda_function" "this" {
│ 
```

**Fix:**

Rebuild Image

```sh
docker build \
  --platform linux/amd64 \
  --provenance=false \
  --sbom=false \
  -t 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest .

```

Push Image to ecr

````sh

```sh
docker push 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest
````

## Issue pushing Image to ECR

```sh
 861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation:latest
The push refers to repository [861580917950.dkr.ecr.eu-west-1.amazonaws.com/portfolio-dev/t212-automation]
cbd417084945: Waiting 
b4a0e9412dab: Waiting 
5d3bb8d7cd0b: Waiting 
1a1041f17cd1: Waiting 
8e0d87e5a2c4: Waiting 
e60b1240a779: Waiting 
b8fa6daf26cb: Waiting 
c55a255fd23b: Waiting 
aaac8b8b6889: Waiting 
adbb8545365e: Waiting 
unknown: unexpected status from HEAD request to https://861580917950.dkr.ecr.eu-west-1.amazonaws.com/v2/portfolio-dev/t212-automation/blobs/sha256:b8fa6daf26cb8ec36e51a9f6b6e752b2bd14807b18eae78f6e7f8d2bfe882f77: 403 Forbidden
(.venv)  ✘ kunmi@Akinkunmis-Air  ~/workspace/projects/engineering/repository/portfolio-platform   28-terraf
```

**Fix:**

- Relogin to ecr
