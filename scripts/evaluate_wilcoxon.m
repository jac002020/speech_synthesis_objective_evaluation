function [goodness] = evaluate_wilcoxon(objective_scores, subjective_scores, opinion_matrix, systems, drawimage)

listeningmeans=subjective_scores;
refmat=opinion_matrix;
refscores=objective_scores;

invdiag=ones(size(refmat))-diag(ones(size(refmat,1),1));


syscount=length(systems);
featcount=size(refscores,2);

testlen=length(subjective_scores);

bigp=cell(size(refscores,2),1);
machinemeans=zeros(syscount,featcount);

for feat=1:size(refscores,2)
    bigp{feat}=ones(length(systems),length(systems));
    for s1=1:length(systems)
        s1start=(s1-1)*testlen+1;
        s1end=s1*testlen;
        machinemeans(s1, feat)=mean(refscores (s1start:s1end, feat ));
        for s2=s1+1:length(systems)
            s2start=(s2-1)*testlen+1;
            s2end=s2*testlen;
            p = signrank( refscores (s1start:s1end, feat ), refscores (s2start:s2end, feat )   );
            bigp{feat}(s1,s2)=p;
            bigp{feat}(s2,s1)=p;
        end
    end
end

betters=zeros(length(systems));
machinebetters=cell(featcount);
for s1=1:length(systems)
    for s2=1:length(systems)
        betters(s1,s2)=listeningmeans(s1)-listeningmeans(s2);
        for feat=1:featcount
             machinebetters{feat}(s1,s2)=-(machinemeans(s1,feat)-machinemeans(s2,feat));
        end
    end
end

confmatr=zeros(featcount,3,3);
% classes in confusion matrix:
% 1 - system A better
% 2 - system B better
% 3 - No difference


% plot with different p-values:
plotfeat=3
clf;
for pval=[0.05]
    %results=zeros(featcount,13);
    results=zeros(featcount,7);
    confmatr=zeros(3,3,featcount);

    for feat = 1:featcount        
        pmat=zeros(syscount,syscount);
        pmat(bigp{feat}<pval)=1;
        pmat=(pmat.*invdiag);
   
        
        directionmatch = triu(sign(machinebetters{feat}).*sign(betters)) ;
        
        significant_dirs=directionmatch.*pmat;
        criticalmatch=directionmatch.*refmat;

        
        %correct=sum(sum( (directionmatch==1).* (pmat==1) .*  (refmat==1) ));

        % Wrong direction:
        
        % Critical error: 
        % Wrong direction, significance correct
        critical_errors= (directionmatch==-1).* (pmat==1) .*  (refmat==1) ;
        critical_errorssum = sum(critical_errors(:));
        
        % Bad error: 
        % Wrong direction, too much significance
        bad_errors =  (directionmatch==-1).* (pmat==1) .*(refmat==0)  ;
        bad_errorssum = sum(bad_errors(:));

        % Missing error: 
        % Wrong direction, not enough significance
        missing_errors =  (directionmatch==-1).* (pmat==0) .*(refmat==1)  ;
        missing_errorssum = sum(missing_errors(:));
        
        % Minor error
        minor_errors =  (directionmatch==-1).* (pmat==0) .*(refmat==0) ;
        minor_errorssum = sum(minor_errors(:));
        
        % False negative
        % Right direction, not enough significance
        false_negative =  (directionmatch==1).* (pmat==0) .*(refmat==1)  ;
        false_negativesum = sum(false_negative(:));
        
        % False positive:
        % Right direction, too much significance
        false_positive = (directionmatch==1).* (pmat==1) .*(refmat==0)  ;
        false_positivesum=sum(false_positive(:));
        
        % Correct significant:
        correctmatch= (directionmatch==1).* (pmat==1) .*  (refmat==1) ;
        correctmiss= (directionmatch==1).* (pmat==0) .*  (refmat==0) ;
        correctsum=sum(correctmatch(:))+sum(correctmiss(:));
        % Correct insignificant:
        %correct_insig=sum(sum( (directionmatch==1).* (pmat==0) .*  (refmat==0) ));

        accuracy=correctsum/(correctsum+false_positivesum+false_negativesum+critical_errorssum+bad_errorssum +missing_errorssum+minor_errorssum );
        precision=sum(correctmatch(:))/(sum(correctmatch(:))+false_positivesum+bad_errorssum+critical_errorssum);
        recall=sum(correctmatch(:))/sum(sum(triu(refmat)));
        
        f1score=2*(precision*recall)/(precision+recall);
        missing=sum(sum( (pmat==0) .* (refmat==1)      ));
        
        directionhit = sum(sum( triu(refmat==  1) .* (directionmatch==1) ) ) / sum(sum(triu(refmat==  1) ) ) ;
        
        confmatr(1,1,feat) = sum(sum( triu((sign(betters)==  1) .* (refmat==  1) .* (sign(machinebetters{feat})==  1) .* (pmat==  1)  )));
        confmatr(1,2,feat) = sum(sum( triu((sign(betters)==  1) .* (refmat==  1) .* (sign(machinebetters{feat})== -1) .* (pmat==  1)  )));
        confmatr(1,3,feat) = sum(sum( triu((sign(betters)==  1) .* (refmat==  1) .* (pmat==  0)  )));
    
        confmatr(2,1,feat) = sum(sum( triu((sign(betters)== -1) .* (refmat==  1) .* (sign(machinebetters{feat})==  1) .* (pmat==  1)  )));
        confmatr(2,2,feat) = sum(sum( triu((sign(betters)== -1) .* (refmat==  1) .* (sign(machinebetters{feat})== -1) .* (pmat==  1)  )));
        confmatr(2,3,feat) = sum(sum( triu((sign(betters)== -1) .* (refmat==  1) .* (pmat==  0)  )));
        
        confmatr(3,1,feat) = sum(sum( triu((refmat==0)  .* (sign(betters)==  1) .*  (pmat==1)  )));
        confmatr(3,2,feat) = sum(sum( triu((refmat==0)  .* (sign(betters)==  -1) .*  (pmat==1) )));
        confmatr(3,3,feat) = sum(sum( triu((refmat== 0) .* (pmat== 0 )  )));
        
        %disp([num2str(pval),', ',num2str(feat),': error: ',num2str(sum(abs(pmat(:)-refmat(:))))]);
        
        %results(feat,:)=[pval feat critical_errorssum bad_errorssum missing_errorssum minor_errorssum false_negativesum false_positivesum correctsum accuracy precision recall f1score];
        results(feat,:)=[pval feat accuracy precision recall f1score directionhit];
        
%        if feat == plotfeat

        if drawimage==feat

            clf
            subplot(1,4,1)
            
            hold on
            for s1=1:length(systems)
                for s2=s1:length(systems)
                    if refmat(s1,s2) == 1
                       rectangle('position',[s1-0.33,s2-0.33,0.66,0.66],'facecolor','k');
                    end
                end
            end
            title('ref')
            axis([0 19 0 19])
            
            set(gca,'ytick',[1:1:18],'yticklabel',['B';'C';'D';'E';'H';'I';'J';'K';'L';'M';'O';'P';'Q';'R';'S';'T';'U';'W'])            
            set(gca,'xtick',[1:1:18],'xticklabel',['B';'C';'D';'E';'H';'I';'J';'K';'L';'M';'O';'P';'Q';'R';'S';'T';'U';'W'])
            % Goddamn manual grid...
            for s1=0.5:1:length(systems)+0.5
                plot([s1,s1], [0,length(systems)+1], 'linestyle', ':');                
                plot([length(systems)+1,0], [s1,s1], 'linestyle', ':');
            end            
            
            
            subplot(1,4,2)
            hold on
            for s1=1:length(systems)
                for s2=s1:length(systems)
                     if refmat(s1,s2) == 1
                       rectangle('position',[s1-0.33,s2-0.33,0.66,0.66],'facecolor','none','edgecolor',[0.8,0.8,0.8]);
                    end                
                    if pmat(s1,s2)*directionmatch(s1,s2) == 1
                       rectangle('position',[s1-0.33,s2-0.33,0.66,0.66],'facecolor','none','edgecolor','green');
                    end
                    if pmat(s1,s2)*directionmatch(s1,s2) == -1
                       rectangle('position',[s1-0.33,s2-0.33,0.66,0.66],'facecolor','none','edgecolor','red');
                    end
                    if correctmatch(s1,s2) == 1
                       rectangle('position',[s1-0.33,s2-0.33,0.66,0.66],'facecolor','green');
                    end
                    if critical_errors(s1,s2) == 1
                       rectangle('position',[s1-0.33,s2-0.33,0.66,0.66],'facecolor','red');
                    end

                end
            end
            axis([0 19 0 19])
            
            %pmat=zeros(syscount,syscount);pmat(bigp{feat}<pval)=1;pmat=pmat.*invdiag;imagesc(1-pmat)
            title(['candidate feat: ',num2str(feat),', pval: ',num2str(pval)])

            set(gca,'ytick',[1:1:18],'yticklabel',['B';'C';'D';'E';'H';'I';'J';'K';'L';'M';'O';'P';'Q';'R';'S';'T';'U';'W'])            
            set(gca,'xtick',[1:1:18],'xticklabel',['B';'C';'D';'E';'H';'I';'J';'K';'L';'M';'O';'P';'Q';'R';'S';'T';'U';'W'])
            % Goddamn manual grid...
            for s1=0.5:1:length(systems)+0.5
                plot([s1,s1], [0,length(systems)+1], 'linestyle', ':');                
                plot([length(systems)+1,0], [s1,s1], 'linestyle', ':');
            end
            
            subplot(1,4,3)
            hold on
            %imagesc(1-(abs(pmat-refmat)))
            
            
            
            for s1=1:length(systems)
                for s2=s1:length(systems)
                    if refmat(s1,s2) == 1
                       rectangle('position',[s1-0.4,s2-0.4,0.66,0.66],'facecolor','k');
                    end
                    
                    if critical_errors(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor','red');
                    end                       
                    if correctmatch(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor','green');
                    end                 
                    if correctmiss(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor',[0.9,1,0.9],'linestyle','none');
                    end    
                    if false_positive(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor',[0.7,1,0.7]);
                    end    
                    if false_negative(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor',[0.7,1,0.7],'linestyle','none');
                    end    
                    if minor_errors(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor',[1,0.9,0.9],'linestyle','none');
                    end  
                    if bad_errors(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor',[1,0.7,0.7]);
                    end                      
                    if missing_errors(s1,s2) == 1
                       rectangle('position',[s1-0.2,s2-0.2,0.66,0.66],'facecolor',[1,0.7,0.7],'linestyle','none');
                    end 
                    
                end
            end
            axis([0 19 0 19])
            title(['err n=',num2str(sum(abs(pmat(:)-refmat(:))))] )
            set(gca,'ytick',[1:1:18],'yticklabel',['B';'C';'D';'E';'H';'I';'J';'K';'L';'M';'O';'P';'Q';'R';'S';'T';'U';'W'])            
            set(gca,'xtick',[1:1:18],'xticklabel',['B';'C';'D';'E';'H';'I';'J';'K';'L';'M';'O';'P';'Q';'R';'S';'T';'U';'W'])
            % Goddamn manual grid...
            for s1=0.5:1:length(systems)+0.5
                plot([s1,s1], [0,length(systems)+1], 'linestyle', ':');                
                plot([length(systems)+1,0], [s1,s1], 'linestyle', ':');
            end
            
            subplot(1,4,4)
            c=confmatr(:,:,feat);
            
            lab={'A->B','B->A', 'A->C','B->C','C->A','C->B'};
            ct=sum(c,2)./3;
            %radarplot( [c(1,2)/ct(1),  c(2,1)/ct(2),  c(1,3)/ct(1),  c(2,3)/ct(2),  c(3,1)/ct(3),  c(3,2)/ct(3) ; ones(1,6)/3  ],lab);
            radarplot( [c(1,2),  c(2,1),  c(1,3),  c(2,3),  c(3,1),  c(3,2) ; ct(1),ct(2),ct(1),ct(2),ct(3),ct(3)  ],lab);
            
        
        end
    end
    %disp('      pval      feat   criterr   baderrors misserr  minor_err  falseneg    falsepos  corr1 ')
         %    0.0500    1.0000   98.0000   46.0000   38.0000   24.0000   22.0000   30.0000   32.0000
     disp('      pval      feat   accuracy precision recall f1score   direction')

    disp(results)
    goodness=results;
end


