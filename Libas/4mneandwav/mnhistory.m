edit invmap_reduce
[lfd_mat, orientations, v] = compute_lfdmat_olaf(loc_mat, sens_mat, method_flag, coor_flag, cntr_of_sphere);
edit lf34capr
plot3(a(:,1), a(:,2), a(:,3))
plot3(a(:,1), a(:,2), a(:,3), '*")
plot3(a(:,1), a(:,2), a(:,3), '*')
plot3(a(:,1), a(:,2), a(:,3))
whos
emegs2d
sensors = [0.06299	0.05858	-0.03262
0.05694	0.07223	-0.00188
0.03931	0.07908	0.02579
-0.06345	0.04454	-0.04954
-0.00000	0.00462	0.09188
]
whos
plot3(sensors(:,1), sensors(:,2), sensors(:,3))
sensors = sensor.*10;
sensors = sensors.*10;
whos
plot3(sensors(:,1), sensors(:,2), sensors(:,3))
plot3(a(:,1), a(:,2), a(:,3))
[lfd_mat, orientations, v] = compute_lfdmat_olaf(a', sensors', 'EEG', 'xyz');
[lfd_mat, orientations] = compute_lfdmat_olaf(a', sensors', 'EEG', 'xyz');
whos
655*3
plot(lfd_mat)
plot(lfd_mat')
save lfd_mat129HCL.dat lfd_mat -ascii
[diploc, lfdmat, data, G, invsol] = invmap_reduce(lfd_mat, .05, pwd, '2face_01.fl40.E1.at2.ar', 'testvlad', elplist, locations, from, to, out_flag, bslvec);
edit mnstart
[diploc, lfdmat, data, G, invsol] = invmap_reduce(lfd_mat, .05, pwd, '2face_01.fl40.E1.at2.ar', 'testvlad', [], sensors', [], [], 'abs', 100:150);
[diploc, lfdmat, data, G, invsol] = invmap_reduce(lfd_mat, .05, pwd, '2face_01.fl40.E1.at2.ar', pwd, [], sensors', [], [], 'abs', 100:150);
emegs2d
