function [sig_filt]=FiltrePasseBas(signal,fs,freq_coupure)
% filtre passe-bas du signal. fs est la fr�quence d'�chantillonage du
% signal. freq_coupure est la fr�quence de coupure du filtre passe-bas

dfiltfreq=freq_coupure/(fs/2);      % calcule la fr�quence de coupure normalis�e
[b,a]=butter(8,dfiltfreq);          % cr�e un filtre passe-bas
sig_filt=filtfilt(b,a,signal);      % applique le filtre au signal

return