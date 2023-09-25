sys = System();

lmc = sys:load("cmgdem");
lmc_stage1 = lmc:select_stage(1);

chart = Chart("Load marginal cost");
chart:add_line(lmc_stage1);

tab = Tab("Load marginal cost");
tab:push(chart);

dash = Dashboard();
dash:push(tab)
dash:save("lmc_dashboard")



