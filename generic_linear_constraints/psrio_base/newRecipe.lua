local hydro = Hydro();

local qverti = hydro:load("qverti"):convert("hm3"):aggregate_blocks(BY_AVERAGE());
local qturbi = hydro:load("qturbi"):convert("hm3"):aggregate_blocks(BY_AVERAGE());

local volfin = hydro:load("volfin");
local volini = hydro:load("volini");
local delta_vol = (volfin - volini);

local dashboard = Dashboard();
local tab = Tab("Generic Linear Constraint Exemple");

local chart_GLC_1 = Chart("Make the turbining equal to 20% of the outflow.");
local H1_tubining = qturbi:select_agent("H1"):rename_agents("H1 - Turbining Outflow");
local H1_outflow  = (qverti + qturbi):select_agent("H1"):rename_agents("H1 - Total Outflow");
chart_GLC_1:add_column_percent(H1_tubining);
chart_GLC_1:add_column_percent(H1_outflow);

tab:push(chart_GLC_1);

local chart_GLC_2 = Chart("Make the final volume greater than or equal to 20% of the volume difference.");
local H2_final_volume = volfin:select_agent("H2"):rename_agents("H2 - Final Volume");
local H2_delta_volume  = delta_vol:select_agent("H2"):rename_agents("H2 - Delta Volume");
chart_GLC_2:add_column(H2_final_volume);
chart_GLC_2:add_column(H2_delta_volume);

tab:push(chart_GLC_2);

dashboard:push(tab);
dashboard:save("GLC_EXAMPLE")