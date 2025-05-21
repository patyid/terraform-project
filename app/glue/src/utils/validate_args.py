def validate_args(args, expected_keys):
    for key in expected_keys:
        if key not in args or not args[key]:
            raise ValueError(f"Parâmetro obrigatório '{key}' não foi fornecido.")
