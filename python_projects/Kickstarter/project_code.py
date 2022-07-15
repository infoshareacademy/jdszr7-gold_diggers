import pandas as pd
import matplotlib as plt
import seaborn as sns
import ipywidgets as widgets
from IPython.display import display, clear_output


#funkcja import pliku
def f_file_import(name:str):
    return pd.read_csv(name)


#funkcja agregująca dane do nowego DF
def aggregate_fun(df, agg_list:list, measure:str):
    agg_df = df.groupby(agg_list)[measure].agg(['count',sum,'mean', 'median']).reset_index()
    agg_df.rename(columns= {'count':'count_x', 'sum':'sum_x', 'mean':'mean_x', 'median':'median_x'}, inplace=True)
    return agg_df

    
#funkcja wykres słupkowy - liczebność - jedna zmienna
def bar_plot_1_var(df, group_var:str, size:tuple = (10,6)):
    df.groupby(group_var)[group_var].count().sort_values(ascending = False).plot(kind = 'bar', figsize = size);
    
    
    
#funkcja wykres słupkowy - liczebność - jedna zmienna - dla dat
def bar_plot_1_var_date(df, group_var:str, size:tuple = (10,6)):
    df.groupby(group_var)[group_var].count().plot(kind = 'bar', figsize = size);
    
    
#funkcja wykres słupkowy - średnia - jedna zmienna + zmienna grupowana
# var1 - zmienna grupująca, var2 - zmienna grupowana
def bar_plot_1_var_mean(df, group_var:str, groupped_var:str):
    df.groupby(group_var)[groupped_var].mean().sort_values(ascending=False).plot(kind='bar', figsize=(10,8));

    
#funkcja wykres słupkowy bar - liczebność - dwie zmienne - col x
def bar_plot_2_var(df, var_col:str, var_x:str, var_y:str, column_wrap:int =3, height_value:float = 4):
    g = sns.catplot(data = df, col = var_col , x = var_x, y=var_y, kind = 'bar', height = height_value, col_wrap=column_wrap,
                    sharex = False)
    g.set_titles('{col_name}');

   
        
#funkcja wykres słupkowy count - liczebność - dwie zmienne - col x
def count_plot_col(df, var_col:str, var_x:str,column_wrap:int =3, height_value:float = 4):
    g = sns.catplot(data = df, col = var1 , x = var2,  kind = 'count', height = height_value, col_wrap=column_wrap)
    g.set_titles('{col_name}');

       
#funkcja 3 zmienne - po aggregujących  
def bar_plot_3_var(df, var_col:str, var_x:str, var_y:str, hue_var:str,groupped_var:str, palette_list:list, column_wrap:int =3, height_value:float = 4):
    df_new = aggregate_fun(df, [var_x, var_col, hue_var], groupped_var )
    g = sns.catplot(data = df_new, col = var_col , x = var_x, y = var_y, hue = hue_var, kind = 'bar', height = height_value, 
                    col_wrap = column_wrap, palette = palette_list, sharex = False)
    g.set_titles('{col_name}');

    
#funkcja bar plot z procentami
def barplot_pct(df, list_2_elements:list):
    #agregujemy po 2 zmiennych, otrzymujemy count, sum, mean, median
    df_new = aggregate_fun(df, list_2_elements, 'ID' )
    
    #zmieniamy nazwę w nowo utworzonym DF, bo wysypuje się na nazwach typu count
    df_new.rename(columns= {'count':'count_y', 'sum':'sum_y', 'mean':'mean_y', 'median':'median_y'}, inplace=True)

    #agregujemy drugiego DF po 1 zmiennej - będziemy brać z tego sumę
    df_new_1 = aggregate_fun(df_new, list_2_elements[1], 'count_y')

    #zmieniamy nazwę drugiego DF, bo wysypuje się na nazwach typu count
    df_new_1.rename(columns= {'count':'count_x', 'sum':'sum_x', 'mean':'mean_x', 'median':'median_x'}, inplace=True)

    #merge'ujemy powyższe DFy, z pierwszego bierzemy count_y, z drugiego sum_x,
    # merge jako inner join, łączenie po XXXXXX
    df_new_2 = pd.merge(df_new[[list_2_elements[0], list_2_elements[1], 'count_y']],
    df_new_1[[list_2_elements[1],'sum_x']], how='inner', on=list_2_elements[1])

    #Tworzymy nową kolumnę procent
    df_new_2['pct'] = df_new_2['count_y']/df_new_2['sum_x'] * 100

    #Odwołanie do funkcji tworzącej wykres
    bar_plot_2_var(df_new_2, list_2_elements[1], list_2_elements[0],'pct', 2,8);
    
    
#funkcja sortująca
def sorting_values(df_agg, value_by:str = 'mean', sorting_var:bool = False):
    return df_agg.sort_values(by =value_by, ascending= sorting_var).reset_index()
    
    
#funkcja filtrująca - 
def filter_lower_equal(df, x, var_bar_plot:list):
    df_zadana_kwota = df[df.usd_goal_real <= x]
    g = barplot_pct(df_zadana_kwota, var_bar_plot)
    
#funkcja tworząca liste unikalnych wartości do widgetów
def unique_value_list(df, col_var:str):
    return list(df[col_var].unique())

#funkcja tworząca liste unikalnych wartości do widgetów sortująca 
def unique_value_list_sorted(df, col_var:str):
    return sorted(list(df[col_var].unique()))
    
    
#funkcja definicja widgetu 
def widget_def(lista:list, descr:str ):
    return widgets.SelectMultiple(
    options=lista,
    value=[lista[0]],
    rows=10,
    description=descr,
    disabled=False)
    
    
def widget_layout(widget1, widget2):
    layout = widgets.Layout(display='flex',
         flex_flow='row',
         border='solid green',
         width='50%')
    return widgets.Box(children=[widget1, widget2], layout=layout)
    
    
    
    
    
    
    
    
    
