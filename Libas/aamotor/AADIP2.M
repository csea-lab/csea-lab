% scanne gesamte Datenreihe mit fft/psd Fenster 128
% zuvor gelaufen: aadip1

clear FF
clear FRE
clear frequenz
clear U
clear O

U = 1:5:(length(F)-128);
O = 129:5:length(F);


for count = 1:length(U)
Pyy = [];

	V = U(count):O(count);

	FF = fft(F(V));

Pyy = FF.*conj(FF)/128;

%für jeweils die ersten 64 Punkte wg. Symmetrie
	
for n = 1 : 64

	if Pyy(n) == max(Pyy)
	frequenz (count) = n;
	end
	
end
end

FRE = (frequenz-1).* 44.44/128;  % ergibt korrekte Frequenz, da Pyy(1)
                                 % Energie für 0Hz angibt

ZEIT= [O];

figure (7)
plot (ZEIT,FRE)
xlabel ('n')
ylabel ('Frequenz')
text(200,2,FILE)