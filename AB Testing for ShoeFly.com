import codecademylib
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
# step 1 print the first 5 rows
print ad_clicks.head()
#step 2 which source had the most views - Google
most_views = ad_clicks.groupby('utm_source').user_id.count().reset_index()
print most_views
#step 3 to create a new column that shows if someone clicked on the ad, looking for a value greater than 0
is_click = lambda x: True if x > 0 else False
ad_clicks['is_click'] = ad_clicks.ad_click_timestamp.apply(is_click)
#print ad_clicks.head(10)
#step 4 percentage of ppl who clicked each source
clicks_by_source = ad_clicks.groupby(['utm_source', 'is_click']).user_id.count().reset_index()
#print clicks_by_source
#step 5 
clicks_pivot = clicks_by_source.pivot(columns='is_click', index='utm_source', values='user_id').reset_index()
#step 6 adding a new column - Yes there was a difference Facebook clicked the most 
clicks_pivot['percent_clicked'] = clicks_pivot[True] / (clicks_pivot[True] + clicks_pivot[False]) * 100
print clicks_pivot
#step 7 - Yes there were 827 people for ad A and B
ad_type_count = ad_clicks.groupby('experimental_group').day.count().reset_index()
print ad_type_count
#step 8 more ppl clicked on A
ad_A_or_ad_B = ad_clicks.groupby(['experimental_group', 'is_click']).day.count().reset_index()
A_or_B_pivot = ad_A_or_ad_B.pivot(columns='is_click', index='experimental_group', values='day').reset_index()
A_or_B_pivot['ad_percent_clicked'] = A_or_B_pivot[True] / (A_or_B_pivot[True] + A_or_B_pivot[False]) * 100
print A_or_B_pivot
#a clicks step 10
a_clicks = ad_clicks[ad_clicks.experimental_group == 'A']
a_clicks_by_day = a_clicks.groupby(['is_click', 'day']).user_id.count().reset_index()
a_clicks_by_day_pivot = a_clicks_by_day.pivot(columns='is_click', index='day', values='user_id').reset_index()
a_clicks_by_day_pivot['day_percent_clicked'] = a_clicks_by_day_pivot[True] / (a_clicks_by_day_pivot[True] + a_clicks_by_day_pivot[False]) * 100
print a_clicks_by_day_pivot
# b clicks step 10
b_clicks = ad_clicks[ad_clicks.experimental_group == 'B']
b_clicks_by_day = b_clicks.groupby(['is_click', 'day']).user_id.count().reset_index()
b_clicks_by_day_pivot = b_clicks_by_day.pivot(columns='is_click', index='day', values='user_id').reset_index()
b_clicks_by_day_pivot['day_percent_clicked'] = b_clicks_by_day_pivot[True] / (b_clicks_by_day_pivot[True] + b_clicks_by_day_pivot[False]) * 100
print b_clicks_by_day_pivot
#step 11
#recommend ad A
