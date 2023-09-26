local main_tab               = Tab("Resume");
local without_constrains_tab = Tab("Case without constraints");
local with_constrains_tab    = Tab("Case with constraints");
local comparison_tab         = Tab("Results");

main_tab:push("## Generic interpolation constraints example 1");
main_tab:push([[ In this case, a generic interpolation constraint was created to make the thermal plants generation T1 and T2, follow the segments described in the interpolation constraint:
]]);
main_tab:push([[$$ \begin{vmatrix} T_1 \\\\ T_2 \end{vmatrix} = \lambda_1 \cdot \begin{vmatrix} 0 \\\\ 0 \end{vmatrix} + \lambda_2 \cdot \begin{vmatrix} 4 \\\\ 1 \end{vmatrix} + \lambda_3 \cdot \begin{vmatrix} 9 \\\\ 4 \end{vmatrix} + \lambda_4 \cdot \begin{vmatrix} 16 \\\\ 8 \end{vmatrix} + \lambda_5 \cdot \begin{vmatrix} 25  \\\\ 15 \end{vmatrix} + \begin{vmatrix} \alpha_1  \\\\ \alpha_1 \end{vmatrix} $$]]);
main_tab:push([[$$ \lambda_k <= y_{k-1} + y_k, \forall k \subset \left[1,5\right] $$]]);
main_tab:push([[$$ \begin{align} \sum_{k=1}^{5} \lambda_k = 1 & \qquad \sum_{k=0}^{5} y_k = 1 \end{align} $$]]);
main_tab:push([[$$ \begin{align} y_0 = 0 & \qquad y_5 = 0 \end{align} $$]]);
main_tab:push([[$$ \begin{align} y = \lbrace 0,1 \rbrace \^6 & \qquad \lambda = \left[0,1\right]\^5 \end{align} $$]]);
main_tab:push([[ Where 𝒄 is the cost of thermal units, 𝑻 are the thermal generation variables, 𝜹 are the slacks of interpolation variables. 𝝀 are the variables for convex combination. 𝒚 are the binary variables for segment selection.
]]);

local demand_chart           = Chart("Demand");
local thermal_capacity_chart = Chart("Thermal capacity");

demand_chart:add_column(System(1):load("demand"):aggregate_blocks(BY_SUM()):convert("MW"));
thermal_capacity_chart:add_column(Thermal(1).max_generation);

main_tab:push(demand_chart);
main_tab:push(thermal_capacity_chart);

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

local generic = Generic(1);

local pT1 = {0,4,9,16,25};
local pT2 = {0,1,4,8,15};
local point_T1 = generic:create("point", "MW", pT1);
local point_T2 = generic:create("point", "MW", pT2);

local tab_vector = {without_constrains_tab,with_constrains_tab};
local case_type  = {"without","with"};
for case = 1, 2 do
    local thermal_generation_chart = Chart("Thermal generation of case " .. case_type[case] .. " constraints");
    local cmo_chart                = Chart("Local marginal prince of case " .. case_type[case] .. " constraints");
    local interpolation_chart = Chart("Interpolation of case " .. case_type[case] .. " constraints");

    local thermal = Thermal(case);
    local bus     = Bus(case);

    local thermal_generation = thermal:load("gerter"):aggregate_blocks(BY_SUM()):convert("MW");
    local cmo_bus            = bus:load("cmgbus"):aggregate_blocks(BY_SUM());

    thermal_generation_chart:add_column(thermal_generation);
    cmo_chart:add_column(cmo_bus);

    interpolation_chart:add_scatter(point_T1,point_T2,"Interpolation_segments",{ lineWidth = 1});
    for stage = 1, thermal_generation:stages() do
        local stage_generation = thermal_generation:select_stage(stage);
        local T1_generation = stage_generation:select_agents({"T1"});
        local T2_generation = stage_generation:select_agents({"T2"});

        interpolation_chart:add_scatter(T1_generation,T2_generation,"Generation in stage " .. stage,{ showInLegend = false , marker = {symbol = "circle"}});
    end

    tab_vector[case]:push(thermal_generation_chart);
    tab_vector[case]:push(interpolation_chart);
    tab_vector[case]:push(cmo_chart);

    for themal = 1, #vector_of_themals do
        vector_thermal_chart[themal]:add_column(thermal_generation:select_agents({themal})
                                    :rename_agents({case_type[case] .. " constraints"}));
    end

    for bus = 1, #vector_of_bus do
        vector_bus_chart[bus]:add_column(cmo_bus:select_agents({bus})
                             :rename_agents({case_type[case] .. " constraints"}));
    end
end

comparison_tab:push("## Thermal Generation");
comparison_tab:push(" To obey the interpolation constraints, the model necessarily needs to decrease the generation of thermal plants T1, the most cheapest one, and increase the generation of T2, the most expensive thermal plant, as depicted in the following chart.");
-- for i = 1, #vector_thermal_chart do
--     comparison_tab:push(vector_thermal_chart[i]);
-- end
comparison_tab:push(vector_thermal_chart);

comparison_tab:push("## Local marginal price");
comparison_tab:push(" The increase in T2 generation, which is more expensive than T1 plant, also results in an increase in the local marginal price.");
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