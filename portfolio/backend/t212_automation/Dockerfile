FROM public.ecr.aws/lambda/python:3.12

RUN python -m pip install --upgrade pip

COPY requirements.txt ${LAMBDA_TASK_ROOT}/

RUN pip3 install --no-cache-dir \
    -r ${LAMBDA_TASK_ROOT}/requirements.txt

COPY . ${LAMBDA_TASK_ROOT}/

CMD ["main.lambda_handler"]