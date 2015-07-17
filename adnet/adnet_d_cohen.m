%% calculate cohen's d

% effect size of difference between group per site
% 4 effect sizes (1 for each site) PER CONNECTION

% load .mat file
d_cohen = zeros(length(list_sig),size(tab,2)); % a connection x site table
for ssite = 1:size(tab,2)
    for ss = 1:(size(list_sig,1))
     
<<<<<<< HEAD
        m_cne = mean(tab{2,ssite}(:,ss));   % mean connectivity of cne
        n_cne = size(tab{2,ssite}(:,ss),1); % number of cne
        std_cne = std(tab{2,ssite}(:,ss));  % std connectivity of cne
    
        m_mci = mean(tab{3,ssite}(:,ss));   % mean connectivity of mci
        n_mci = size(tab{3,ssite}(:,ss),1); % number of mci
        std_mci = std(tab{3,ssite}(:,ss));  % std connectivity of mci
=======
        m_cne   = mean(tab{2,ssite}(:,ss));   % mean connectivity of cne
        n_cne   = size(tab{2,ssite}(:,ss),1); % number of cne
        std_cne = std(tab{2,ssite}(:,ss));    % std connectivity of cne
    
        m_mci   = mean(tab{3,ssite}(:,ss));   % mean connectivity of mci
        n_nci   = size(tab{3,ssite}(:,ss),1); % number of mci
        std_mci = std(tab{3,ssite}(:,ss));    % std connectivity of mci
>>>>>>> 3946560c9ff31021ad2977b7ce1d0610ce82284f
    
        s_pool = sqrt(((n_mci-1)*std_mci^2 + (n_cne-1)*std_cne^2)/(n_mci+n_cne-2)); % pooled standard deviation
        d_cohen(ss,ssite) = (m_mci - m_cne)/s_pool;
    end
<<<<<<< HEAD
end
=======
end
>>>>>>> 3946560c9ff31021ad2977b7ce1d0610ce82284f