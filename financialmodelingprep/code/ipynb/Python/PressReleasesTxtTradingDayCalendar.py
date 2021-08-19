#!/usr/bin/env python


import os
import pandas as pd
from datetime import timedelta
import zipline
from zipline.data import bundles
from zipline.utils.calendars import get_calendar
from zipline.pipeline.data import USEquityPricing
from zipline.pipeline.factors import CustomFactor
from zipline.research.utils import get_pricing, create_data_portal, create_pipeline_engine

os.environ['ZIPLINE_ROOT'] = os.path.join(os.getcwd(), '.zipline')

trading_calendar = get_calendar('NYSE')
bundle_name = 'alpaca_api'
start_date = pd.Timestamp('2015-12-31', tz='utc')
pipeline_start_date = start_date + timedelta(days=365*2)
while not trading_calendar.is_session(pipeline_start_date):
    pipeline_start_date += timedelta(days=1)
print(f"start date: {pipeline_start_date}")
end_date = pd.Timestamp('2020-12-28', tz='utc')
print(f"end date: {end_date}")
data_portal = create_data_portal(bundle_name, trading_calendar, start_date)
engine = create_pipeline_engine(bundle_name)


