N_cases = PSR.studies();

local factor = {"1.0","1.2","1.5"};

local dashboard   = Dashboard();
local resume_tab  = Tab("Resume");
local results_tab  = Tab("Results");

resume_tab:push("## Dashboard resume");
resume_tab:push("The demand fluctuates based on its sensitivity. In line with this, this dashboard compares the results of three cases, with sensitivity factors of 1, 1.2, and 1.5, respectively, to demonstrate how they vary in response to changes in the factor.");

local demand_chart  = Chart("Case demand");
local cmo_chart     = Chart("Case marginal cost");
local thermal_chart = Chart("Case thermal generation");
local defict_chart  = Chart("Case defict");

demand_chart:add_line(Thermal(1).max_generation:aggregate_agents(BY_SUM(),"System capacity"));

local thermal_agents_names = Thermal(1):labels();
local thermal_generation   = {{}, {}};

for case = 1,N_cases do
    local thermal = Thermal(case);
    local bus     = Bus(case);
    local system  = System(case);

    local demand = system:load("demand"):convert("MW"):aggregate_blocks(BY_AVERAGE());
    local cmo    = bus:load("cmgbus"):aggregate_blocks(BY_SUM());
    local gerter = thermal:load("gerter"):convert("MW"):aggregate_blocks(BY_AVERAGE());
    local defcit = system:load("defcit"):convert("MW"):aggregate_blocks(BY_AVERAGE());

    demand_chart:add_column(demand:add_suffix("_" .. factor[case]));
    defict_chart:add_column(defcit:add_suffix("_" .. factor[case]));

    cmo_chart:add_column(cmo:add_suffix("_" .. factor[case]));

    local thermal_agents = #gerter:agents();
    for agent = 1,thermal_agents do
        table.insert(thermal_generation[agent],gerter:select_agents({agent}):rename_agents({factor[case]}))
    end

end

for agent = 1,#thermal_generation do
    thermal_chart:add_categories(concatenate(thermal_generation[agent]), thermal_agents_names[agent], {xLabel  = "LOAD FACTOR"});
end

results_tab:push("## System results");
results_tab:push("As expected, the demand varies according to sensitivity factor value.");
results_tab:push(demand_chart);
results_tab:push("Observing that the capacity is exceeded in the case with a sensitivity factor of 1.5, it's understandable why a deficit occurs in this particular scenario.");
results_tab:push(defict_chart);

results_tab:push("## Thermal results");
results_tab:push("As the demand increases, the following adjustments occur: first, the least costly thermal plant (T1) increases its dispatch up to its maximum capacity; second, the more expensive thermal plant (T2) increases its generation up to its maximum capacity as well.");
results_tab:push(thermal_chart);

results_tab:push("## Marginal cost results");
results_tab:push("In the first two cases (factors 1 and 1.2), there is no deficit, and as a result, the marginal cost is determined by the cost of the marginal plant. However, in the last case, as expected, the model detects a deficit, and therefore, the local marginal price is defined by the deficit cost.");
results_tab:push(cmo_chart);

dashboard:push(resume_tab);
dashboard:push(results_tab);

dashboard:save("COMPARISON_LOAD_FACTOR")