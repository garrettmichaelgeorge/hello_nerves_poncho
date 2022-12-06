import numpy as np

def process_data(data_1, data_2, data_3) -> tuple:
    if np.mean(data_1 + data_2 + data_3) >= 10:
        return (True, "Good job!")
    else:
        return (False, "Oh no!")
