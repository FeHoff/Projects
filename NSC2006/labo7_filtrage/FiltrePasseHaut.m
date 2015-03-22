function [sig_filt]=FiltrePasseHaut(signal,fs,freq_coupure)
% filtre passe-haut du signal. fs est la fr�quence d'�chantillonage du
% signal. freq_coupure est la fr�quence de coupure du filtre passe-haut

dfiltfreq=freq_coupure/(fs/2);      % calcule la fr�quence de coupure normalis�e
[b,a]=cheby1(8,dfiltfreq,'high');   % cr�e un filtre passe-haut
sig_filt=filtfilt(b,a,signal);      % applique le filtre au signal
toto
return