
from app.dca import dca

# ==========================================
# AWS LAMBDA ENTRYPOINT
# ==========================================


def lambda_handler(event, context):
    return dca()


if __name__ == "__main__":
    print("Starting local execution...")

    result = dca()
    
    print("Execution Result:", result)
