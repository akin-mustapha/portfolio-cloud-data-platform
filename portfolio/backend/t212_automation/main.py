from src.dca import dca

# ==========================================
# AWS LAMBDA ENTRYPOINT
# ==========================================


def lambda_handler(event, context):
    try:
        res = dca()
    except Exception as e:
        raise e
    return res

if __name__ == "__main__":
    print("Starting local execution...")

    result = dca()

    print("Execution Result:", result)
