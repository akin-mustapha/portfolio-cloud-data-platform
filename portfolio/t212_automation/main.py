
from app.dca import dca

# ==========================================
# AWS LAMBDA ENTRYPOINT
# ==========================================


def lambda_handler(event, context):
    return dca()