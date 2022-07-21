import pandas as pd
import matplotlib as plt
import seaborn as sns
import ipywidgets as widgets
from ipywidgets import Layout
from IPython.display import display, clear_output


#funkcja import pliku
def f_file_import(name:str):
    return pd.read_csv(name)


#funkcja agregująca dane do nowego DF
def aggregate_fun(df, agg_list:list, measure:str):
    agg_df = df.groupby(agg_list)[measure].agg(['count',sum,'mean', 'median']).reset_index()
    agg_df.rename(columns= {'count':'count_x', 'sum':'sum_x', 'mean':'mean_x', 'median':'median_x'}, inplace=True)
    return agg_df


#funkcja bar plot z procentami
def barplot_pct(df, lista_2_elementy:list , kolor='pastel', x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    #agregujemy po 2 zmiennych, otrzymujemy count, sum, mean, median
    df_new = aggregate_fun(df, lista_2_elementy, 'ID' )
    
    #zmieniamy nazwę w nowo utworzonym DF, bo wysypuje się na nazwach typu count
    df_new.rename(columns= {'count_x':'count_y', 'sum_x':'sum_y', 'mean_x':'mean_y', 'median_x':'median_y'}, inplace=True)

    #agregujemy drugiego DF po 1 zmiennej - będziemy brać z tego sumę
    df_new_1 = aggregate_fun(df_new, lista_2_elementy[1], 'count_y')
        #['main_category']

    #merge'ujemy powyższe DFy, z pierwszego bierzemy count_y, z drugiego sum_x,
    # merge jako inner join, łączenie po XXXXXX
    df_new_2 = pd.merge(df_new[[lista_2_elementy[0], lista_2_elementy[1], 'count_y']],
    df_new_1[[lista_2_elementy[1],'sum_x']], how='inner', on=lista_2_elementy[1])

    #Tworzymy nową kolumnę procent
    df_new_2['pct'] = df_new_2['count_y']/df_new_2['sum_x'] * 100

    #Odwołanie do funkcji tworzącej wykres
    bar_plot_2_var(df_new_2, lista_2_elementy[1], lista_2_elementy[0],'pct', kolor,2,8, x_label=x_label, y_label=y_label, title_fig=title_fig);


#funkcja wykres słupkowy - liczebność - dwie zmienne - col x
def bar_plot_2_var(df, var_col:str, var_x:str, var_y:str, palette_list:list, column_wrap:int =3, height_value:float = 4, x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    g = sns.catplot(data = df, col = var_col , x = var_x, y=var_y, kind = 'bar', height = height_value, col_wrap=column_wrap, palette = palette_list,sharex = False)
    g.set_titles('{col_name}')
    g.set_axis_labels(x_label, y_label)
    g.fig.suptitle(title_fig,y=1, fontsize=16, fontweight='semibold')


#funkcja wykres słupkowy - liczebność - dwie zmienne - col x
def count_plot_col(df, var1:str, var2:str,column_wrap:int =3, height_value:float = 4,  x_label:str='x', y_label:str='y', title_fig:str='Tytuł',palette_list:list='pastel'):
    g = sns.catplot(data = df, col = var1 , x = var2,  kind = 'count',palette = palette_list, height = height_value, col_wrap=column_wrap, sharex=False)
    g.set_titles('{col_name}');
    g.set_axis_labels(x_label, y_label)
    g.fig.suptitle(title_fig,y=1.01, fontsize=16, fontweight='semibold');


#funkcja 3 zmienne - po agregujących  
def bar_plot_3_var(df, var_col:str, var_x:str, var_y:str, hue_var:str,zmienna_ilosciowa:str, palette_list:list, column_wrap:int =3, height_value:float = 4, x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    df_new = aggregate_fun(df, [var_x, var_col, hue_var], zmienna_ilosciowa )
    g = sns.catplot(data = df_new, col = var_col , x = var_x, y = var_y, hue = hue_var, kind = 'bar', height = height_value, col_wrap = column_wrap, palette = palette_list, sharex = False)
    g.set_titles('{col_name}')
    g.set_axis_labels(x_label, y_label)
    g.fig.suptitle(title_fig,y=1, fontsize=16, fontweight='semibold');


#funkcja 3 zmienne - bez agregacji   
def bar_plot_3_var_no_agg(df, var_col:str, var_x:str, var_y:str, hue_var:str, palette_list:list, column_wrap:int =3, height_value:float = 4.0, x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    g = sns.catplot(data = df, col = var_col , x = var_x, y = var_y, hue = hue_var, kind = 'bar', height = height_value, col_wrap = column_wrap, palette = palette_list, sharex = False)
    g.set_titles('{col_name}')
    g.set_axis_labels(x_label, y_label)
    g.fig.suptitle(title_fig,y=1.005, fontsize=16, fontweight='semibold');


#funkcja wykres słupkowy - liczebność - jedna zmienna
def bar_plot_1_var(name, group_var:str, size:tuple = (10,6), colors = ['r', 'g'], alph=1, x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
   g = name.groupby(group_var)[group_var].count().sort_values(ascending = False).plot(kind = 'bar', figsize = size, color=colors,alpha=alph)
   g.set(xlabel=x_label, ylabel=y_label, title=title_fig)


#funkcja wykres słupkowy - liczebność - jedna zmienna - dla dat
def bar_plot_1_var_date(name, group_var:str, size:tuple = (10,6), x_label:str='x', y_label:str='y',colors=['#227DD6'], title_fig:str='Tytuł'):
    g = name.groupby(group_var)[group_var].count().plot(kind = 'bar',color = colors, figsize = size)
    g.set(xlabel=x_label, ylabel=y_label, title=title_fig);


#funkcja wykres słupkowy - średnia - jedna zmienna + zmienna grupowana
def bar_plot_1_var_mean(df, group_var:str, groupped_var:str, x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    g = df.groupby(group_var)[groupped_var].mean().sort_values(ascending=False).plot(kind='bar', figsize=(10,8))
    g.set(xlabel=x_label, ylabel=y_label, title=title_fig);
    
    
#funkcja sortująca
def sorting_values(df_agg, value_by:str = 'mean', sorting_var:bool = False):
    return df_agg.sort_values(by =value_by, ascending= sorting_var).reset_index()


#funkcja filtrująca 
def filter_greater_equal(df, x, var_bar_plot:list, color='pastel', x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    df_zadana_kwota = df[df.usd_goal_real >= x]
    g = barplot_pct(df_zadana_kwota, var_bar_plot, color, x_label, y_label, title_fig)

    
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
    layout=Layout(width='60%', height='200px'),
    value=[lista[0]],
    rows=10,
    description=descr,
    disabled=False)


#funkcja zestawiająca widgety obok siebie - layout
def widget_layout(widget1, widget2):
    layout = widgets.Layout(display='flex',
         justify_content='space-between',
         align_items='center',                
         flex_flow='row',
         border='solid green',
         width='70%',
         style= {'description_width': 'initial'} )
    return widgets.Box(children=[widget1, widget2], layout=layout)


#funkcja bar plot z procentami
def barplot_pct_3_var(df, lista_3_elementy:list, x_label:str='x', y_label:str='y', title_fig:str='Tytuł'):
    #agregujemy po 2 zmiennych, otrzymujemy count, sum, mean, median
    df_new = aggregate_fun(df, lista_3_elementy, 'ID' )
    
    #zmieniamy nazwę w nowo utworzonym DF, bo wysypuje się na nazwach typu count
    df_new.rename(columns= {'count_x':'count_y', 'sum_x':'sum_y', 'mean_x':'mean_y', 'median_x':'median_y'}, inplace=True)

    #agregujemy drugiego DF po 2 elementach - będziemy brać z tego sumę
    df_new_1 = aggregate_fun(df_new, lista_3_elementy[0:2], 'count_y')

    #merge'ujemy powyższe DFy, z pierwszego bierzemy count_y, z drugiego sum_x,
    # merge jako inner join, łączenie po XXXXXX
    df_new_2 = pd.merge(df_new[[lista_3_elementy[0], lista_3_elementy[1],lista_3_elementy[2], 'count_y']],
    df_new_1[[lista_3_elementy[0],lista_3_elementy[1],'sum_x']], how='inner', on=lista_3_elementy[0:2])

    #Tworzymy nową kolumnę procent
    df_new_2['pct'] = df_new_2['count_y']/df_new_2['sum_x'] * 100

    #Odwołanie do funkcji tworzącej wykres
    bar_plot_3_var_no_agg(df_new_2,'main_category', 'duration', 'pct', 'state', ['#FF6666','#66B266'], 1, 10.0, x_label=x_label, y_label=y_label, title_fig=title_fig)



