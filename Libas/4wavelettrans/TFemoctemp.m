%TFemoctemp
function [] = TFemoctemp(elecvec,taxis, faxis, taxispart, faxispart);

load GM_bslCSmin.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,1), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]), colorbar, title('bsl CS minus')


load GM_bslCSplus.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,5), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]),colorbar, title('bsl CS plus')


load GM_acq1CSmin.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,2), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]),colorbar, title('acq 1 CS minus')


load GM_acq1CSplus.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,6), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]),colorbar, title('acq 1 CS plus')


load GM_acq2CSmin.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,3), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]),colorbar, title('acq 2 CS minus')


load GM_acq2CSplus.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,7), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]),colorbar, title('acq 2 CS plus')


load GM_extiCSmin.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,4), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18), caxis([0.8 1.1]),colorbar, title('exti  CS minus')


load GM_extiCSplus.WA_GM.mat

[outWaMat] = bslcorrWAMat(avgpower, [30:60]);

subplot(2,4,8), contourf(taxis(taxispart), faxis(faxispart), squeeze(mean(outWaMat(elecvec,taxispart,faxispart)))', 18),caxis([0.8 1.1]), colorbar, title('exti  CS plus')






