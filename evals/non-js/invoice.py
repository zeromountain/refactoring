def print_invoice(raw: str, customers: dict) -> str:
    parts = raw.split("|")
    cid = parts[0]
    lines = parts[1:]
    c = customers[cid]
    total = 0
    disc = 0
    out = ""
    for l in lines:
        sku, q, p = l.split(",")
        amt = int(q) * int(p)
        if c["type"] == "vip":
            disc += amt * 0.2
        elif c["type"] == "member":
            disc += amt * 0.1
        total += amt
        out += f"{sku} {q} {amt}\n"
    if c["type"] == "vip":
        fee = 0
    elif c["type"] == "member":
        fee = 0 if total > 50000 else 2500
    else:
        fee = 3000
    out += f"total {total - disc + fee}\n"
    if c["type"] == "vip":
        out += "VIP thanks\n"
    return out
