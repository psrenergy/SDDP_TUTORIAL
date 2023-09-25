local main_tab               = Tab("Resume");
local without_constrains_tab = Tab("Case without constraints");
local with_constrains_tab    = Tab("Case with constraints");
local comparison_tab         = Tab("Results");

main_tab:push("## Generic linear constraints example 2");
main_tab:push([[ In this case, a generic linear constraint has been established to ensure that the turbinig is  equal to 20% of the delta volume between stages in Hydro plant H2. The following constraints have been implemented:
]]);
main_tab:push("$$ Gvar_i + \\alpha_{1,i} = Vfin_i - Vini_i, \\forall i \\subset H $$");
main_tab:push("$$ Turb_i + \\alpha_{2,i} >= Gvar_i, \\forall i \\subset H $$");

main_tab:push([[ Where H is the set of hydro plants, G〖var〗_i represents generic variables associated with each hydro unit, Vfin_i is the final volume, Vini_i is the initial volume of each hydro plant, Tub_i represents the turbining of hydro unit i and δ_(j,i) is the slack variable for penalty of each constraint.
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

    local hydro   = Hydro(case);
    local thermal = Thermal(case);
    local bus     = Bus(case);

    local hydro_generation   = hydro:load("gerhid"):aggregate_blocks(BY_SUM()):convert("MW");
    local thermal_generation = thermal:load("gerter"):aggregate_blocks(BY_SUM()):convert("MW");
    local cmo_bus            = bus:load("cmgbus"):aggregate_blocks(BY_SUM());
    local volfin             = hydro:load("volfin"):aggregate_blocks(BY_AVERAGE());
    local volini             = hydro:load("volini"):aggregate_blocks(BY_AVERAGE());
    local qturbi             = hydro:load("qturbi"):convert("hm3"):aggregate_blocks(BY_AVERAGE());

    hydro_generation_chart:add_column(hydro_generation);
    thermal_generation_chart:add_column(thermal_generation);
    cmo_chart:add_column(cmo_bus);

    tab_vector[case]:push(hydro_generation_chart);
    tab_vector[case]:push(thermal_generation_chart);
    tab_vector[case]:push(cmo_chart);

    for i,hydro in ipairs(vector_of_hydros) do
        local volume_chart = Chart("Turbinig x delta volume " .. case_type[case] .. " constraints - " .. hydro);
        volume_chart:add_column(qturbi:select_agent(hydro):rename_agents({"Turb"}));
        volume_chart:add_column((volfin-volini):select_agent(hydro):rename_agents({"Delta volume"}));
        tab_vector[case]:push(volume_chart);

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
comparison_tab:push(" To comply with the established generic constraint, which specifies that turbine discharge should be equal to 20% of the change in volume between stages, the model set the generation from H2 to zero. This was the only viable solution.");
-- for i = 1, #vector_hydro_chart do
--     comparison_tab:push(vector_hydro_chart[i]);
-- end
comparison_tab:push(vector_hydro_chart);

comparison_tab:push("## Thermal Generation");
comparison_tab:push(" To offset the loss in hydro generation, it is necessary to increase the generation of thermal plant T2, as depicted in the following chart.");
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