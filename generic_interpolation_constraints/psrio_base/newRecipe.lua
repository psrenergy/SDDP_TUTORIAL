local thermal = Thermal();
local gerter = thermal:load("gerter"):convert("MW"):aggregate_blocks(BY_AVERAGE());

local dashboard = Dashboard();
local tab = Tab("Generic Interpolation Constraints");

local chart = Chart("Interpolation Constraints");
chart:add_column(gerter);

tab:push(chart);
dashboard:push(tab);

dashboard:save("GLC_EXAMPLE")