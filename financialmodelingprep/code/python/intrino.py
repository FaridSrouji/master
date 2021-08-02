from __future__ import print_function
import time
import intrinio_sdk as intrinio
from intrinio_sdk.rest import ApiException

intrinio.ApiClient().set_api_key('OjA4NWQ0NzhiMWE3ZDk2NTNjZjU2OWY4MTI0MzlkYzAx')
intrinio.ApiClient().allow_retries(True)

page_size = 100
next_page = ''

response = intrinio.CompanyApi().get_all_company_news(page_size=page_size, next_page=next_page)
print(response)
    
file_str = '/Users/Farid Srouji/Documents/Research/VIXInterplaySentiment/master/dataintrino.json'
# print(file_str)
f = open(file_str, "a", encoding='utf-8')
#print(str(one_press_release))
f.write(str(response))
f.close()
