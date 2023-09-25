local main_tab               = Tab("Resume");
local without_constrains_tab = Tab("Case without constraints");
local with_constrains_tab    = Tab("Case with constraints");
local comparison_tab         = Tab("Results");

main_tab:push("## Generic linear constraints example 1");
main_tab:push([[ In this case, a generic linear constraint was created for make the turbining of hydro plant H1 equal to 20% of its outflow. In order of that, the following constraint was implemed for:
]]);
main_tab:push("$$ Tur_i + \\alpha_i = 0.2 \\cdot Outf_i, \\forall i \\subset H $$");

main_tab:push([[ Where H is the set of hydro plants, Tub_i represents the turbining of hydro unit i, Outf_i is the outflow of hydro unit i, and δ_i is the slack variable for penalty.
]]);

local demand_chart           = Chart("Demand");
local hydro_capacity_chart   = Chart("Hydro capacity");
local thermal_capacity_chart = Chart("Thermal capacity");

demand_chart:add_column(System(1):load("demand"):aggregate_blocks(BY_SUM()):convert("MW"));
hydro_capacity_chart:add_column(Hydro(1).max_generation);
thermal_capacity_chart:add_column(Thermal(1).max_generation);

main_tab:push(demand_chart);
main_tab:push(hydro_capacity_chart);
main_tab:push(thermal_capacity_chart);

local vector_hydro_chart = {};
local vector_of_hydros = Hydro(1):labels();
for _,hydro in ipairs(vector_of_hydros) do
    table.insert(vector_hydro_chart,Chart(hydro))
end

local vector_thermal_chart = {};
local vector_of_themals = Thermal(1):labels();
for _,thermal in ipairs(vector_of_themals) do
    table.insert(vector_thermal_chart,Chart(thermal))
end

local vector_bus_chart = {};
local vector_of_bus = Bus(1):labels();
for _,bus in ipairs(vector_of_bus) do
    table.insert(vector_bus_chart,Chart(bus))
end

local tab_vector = {without_constrains_tab,with_constrains_tab};
local case_type  = {"without","with"};
for case = 1, 2 do
    local hydro_generation_chart   = Chart("Hydro generation of case " .. case_type[case] .. " constraints");
    local thermal_generation_chart = Chart("Thermal generation of case " .. case_type[case] .. " constraints");
    local cmo_chart                = Chart("Local marginal prince of case " .. case_type[case] .. " constraints");
    local outflow_chart            = Chart("Outflow " .. case_type[case] .. " constraints");

    local hydro   = Hydro(case);
    local thermal = Thermal(case);
    local bus     = Bus(case);

    local hydro_generation   = hydro:load("gerhid"):aggregate_blocks(BY_SUM()):convert("MW");
    local thermal_generation = thermal:load("gerter"):aggregate_blocks(BY_SUM()):convert("MW");
    local cmo_bus            = bus:load("cmgbus"):aggregate_blocks(BY_SUM());
    local qverti             = hydro:load("qverti"):convert("m3/s"):aggregate_blocks(BY_SUM());
    local qturbi             = hydro:load("qturbi"):convert("m3/s"):aggregate_blocks(BY_SUM());
    local volfin             = hydro:load("volfin"):aggregate_blocks(BY_AVERAGE());
    local volini             = hydro:load("volini"):aggregate_blocks(BY_AVERAGE());

    hydro_generation_chart:add_column(hydro_generation);
    thermal_generation_chart:add_column(thermal_generation);
    cmo_chart:add_column(cmo_bus);
    outflow_chart:add_column_percent(qturbi:add_suffix(" turb"))
    outflow_chart:add_column_percent(qverti:add_suffix(" vert"))

    tab_vector[case]:push(hydro_generation_chart);
    tab_vector[case]:push(thermal_generation_chart);
    tab_vector[case]:push(cmo_chart);
    tab_vector[case]:push(outflow_chart);

    for i,hydro in ipairs(vector_of_hydros) do
        vector_hydro_chart[i]:add_column(hydro_generation:select_agents({hydro})
                                 :rename_agents({case_type[case] .. " constraints"}));
    end

    for themal = 1, #vector_of_themals do
        vector_thermal_chart[themal]:add_column(thermal_generation:select_agents({themal})
                                    :rename_agents({case_type[case] .. " constraints"}));
    end

    for bus = 1, #vector_of_bus do
        vector_bus_chart[bus]:add_column(cmo_bus:select_agents({bus})
                             :rename_agents({case_type[case] .. " constraints"}));
    end
end

comparison_tab:push("## Hydro Generation");
comparison_tab:push(" To respect the established generic constraint, which stipulates that turbine discharge should be equal to 20% of the total outflow, the generation from H1 must be reduced. It's worth noting that this constraint compels the plant to spill any excess water.");
-- for i = 1, #vector_hydro_chart do
--     comparison_tab:push(vector_hydro_chart[i]);
-- end
comparison_tab:push(vector_hydro_chart);

comparison_tab:push("## Thermal Generation");
comparison_tab:push(" To offset the loss in hydro generation, it is necessary to increase the generation of thermal plants T1 and T2, as depicted in the following chart.");
-- for i = 1, #vector_thermal_chart do
--     comparison_tab:push(vector_thermal_chart[i]);
-- end
comparison_tab:push(vector_thermal_chart);

comparison_tab:push("## Local marginal price");
comparison_tab:push(" The increase in thermal generation, which is more expensive than hydro generation, also results in an increase in the local marginal price.");
-- for i = 1, #vector_bus_chart do
--     comparison_tab:push(vector_bus_chart[i]);
-- end
comparison_tab:push(vector_bus_chart);

local dashboard = Dashboard();
dashboard:push(main_tab              );
dashboard:push(without_constrains_tab);
dashboard:push(with_constrains_tab   );
dashboard:push(comparison_tab        );

dashboard:save("dashboard")