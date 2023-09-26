-- soma total dos custos
local sddpcoped = require("sddp-reports/sddpcoped"); 
sddpcoped():save("bm_total_cost", {csv=true, remove_zeros=true});

-- soma anual das gerações
local thermal = Thermal();
thermal:load("gerter")
    :aggregate_agents(BY_SUM(), Collection.SYSTEM)
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)
    :save("bm_thermal_gen", {csv=true});

local hydro = Hydro();
hydro:load("gerhid")
    :aggregate_agents(BY_SUM(), Collection.SYSTEM)
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)
    :save("bm_hydro_gen", {csv=true});

local renewable = Renewable();
renewable:load("gergnd")
    :aggregate_agents(BY_SUM(), Collection.SYSTEM)
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)
    :save("bm_renw_gen", {csv=true});

local battery = Battery();
battery:load("gerbat")
    :aggregate_agents(BY_SUM(), Collection.SYSTEM)
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)
    :save("bm_bat_gen", {csv=true});

local system = System();
system:load("defcit")
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)
    :save("bm_deficit_gen", {csv=true});

-- risco anual de deficit
local defcit_risk = require("sddp/defcit_risk");
defcit_risk():save("bm_deficit_risk", {csv=true});

-- média anual do custo marginal
local sddpcmga = require("sddp-reports/sddpcmga")
sddpcmga():save("bm_cmg_avg", {csv=true});
