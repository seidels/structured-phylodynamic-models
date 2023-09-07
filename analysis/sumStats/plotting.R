
plot_sumstats = function(migration_rate = "mr01", cols){

  p = ggplot(data = subset(newmetric,subset = parameter == migration_rate), aes(x=case, y = value, col=Model, fill=Model))+

    geom_point(position = position_dodge(0.5), size=2) +
    scale_size_manual(values = c(14,14,14)) +
    facet_wrap(.~ metric, scales = "free_y") + theme_light() +
    geom_errorbar(aes(ymin=value-sd/2, ymax=value + sd/2),
                  width=0.1, position = position_dodge(0.5))+
    scale_fill_manual(values = cols)+
    scale_color_manual(values = cols)+

    # add desired values
    geom_hline(data = data.frame(yint=1.0, metric="Coverage"), aes(yintercept=yint), linetype="dashed", colour="#990000", alpha=0.6)+
    geom_hline(data = data.frame(yint=0.0, metric="HPD width"), aes(yintercept=yint), linetype="dashed", colour="#990000", alpha=0.6)+
    geom_hline(data = data.frame(yint=0.0, metric="RMSE"), aes(yintercept=yint), linetype="dashed", colour="#990000", alpha=0.6) +

    theme_bw() + theme(legend.position = "top", text = element_text(family = "serif"), strip.background = element_rect(colour="black",
                                                                                                                       fill="white"))+

    xlab("Migration cases") +
    ylab("")

  return(p)
}
