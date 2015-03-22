function [sig_filt]=FiltrePasseBande(signal,fs,freq_coupure_basse,freq_coupure_haute)
% filtre passe-bande du signal. fs est la fr�quence d'�chantillonage du signal. 
% freq_coupure_basse est la fr�quence basse de coupure du filtre passe-bande
% freq_coupure_haute est la fr�quence haute de coupure du filtre passe-bande

dfiltfreqb=freq_coupure_basse/(fs/2);      % calcule la fr�quence de coupure normalis�e
dfiltfreqh=freq_coupure_haute/(fs/2);      % calcule la fr�quence de coupure normalis�e
[b,a]=cheby1(5,5,[dfiltfreqb,dfiltfreqh]);   % cr�e un filtre passe-haut
sig_filt=filtfilt(b,a,signal);      % applique le filtre au signal

return