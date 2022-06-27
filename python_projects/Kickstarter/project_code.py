import pandas as pd
import matplotlib as plt

def f_file_import(name:str):
    return pd.read_csv(name)

#funkcja wykres liczebność jedna zmienna
def f_barplot_1_var(name:str, var:str):
    return name.groupby(var)[var].count().sort_values(ascending = False).plot(kind = 'bar', figsize = (10,6));


def f_barplot_2_var_count(name:str, var1:str, var2:str):
    return sns.catplot(data = name, col = var1, x = var2, y = 'count', kind = 'bar');

# var1 - zmienna grupująca, var2 - zmienna grupowana
def f_barplot_2_var_mean(name:str, var1:str, var2:str):
    return df_clean.groupby(var1)[var2].mean().sort_values(ascending=False).plot(kind='bar', figsize=(10,8));