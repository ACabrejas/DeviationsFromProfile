def d2lm_tag(name):
    return "{http://datex2.eu/schema/2/2_0}"+name

def xsi_tag(name):
    return "{http://www.w3.org/2001/XMLSchema-instance}"+name

def to_bool(val):
    if val == "true":
        return 1
    elif val == "false":
        return 0
    else:
        raise ValueError("Input should be either 'true' or 'flase'")
