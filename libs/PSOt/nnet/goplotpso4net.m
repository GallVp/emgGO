% goplotpso4net.m
% specialized graphing module for neural net training using PSO
% used in conjunction with trainpso

% Brian Birge
% Rev 1.0
% 3/10/06

% setup figure, change this for your own machine
 clf
% set(gcf,'Position',[971    57   626   474]); % home
 set(gcf,'Position',[ 653    30   626   474]);  % PP
 set(gcf,'Doublebuffer','on');
 set(gcf,'color','k');
 set(gcf,'InvertHardCopy','off');
 
% error plot, upper right
subplot('position',[.7,.6,.27,.32]);
[dum,numinputs]=size(net.IW{1});
tmpind=find(net.layerConnect~=0);
[numoutputs,dum]=size(net.LW{tmpind(end)});
if numinputs == 1 & numoutputs == 1
 
 plot(Pd{1},Tl{end},'y','linewidth',2)
 
 hold on
 [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,gbest,Pd,Tl,Ai,Q,TS);

 plot(Pd{1},Ac{end},'r')
 hold off
 xlabel('Input')
 ylabel('Output')
 title('Function Approximator Fitting','color','m','fontweight','bold');
else
 semilogy(tr(find(~isnan(tr))),'color','r','linewidth',2)
 
 %plot(tr(find(~isnan(tr))),'color','m','linewidth',2)
 xlabel('epoch','color','y')
 ylabel('gbest val.','color','y')
 title('Gbest vs. Iterations','color','m','fontweight','bold')
 grid on
 %axis tight
end

 set(gca,'Xcolor','y')
 set(gca,'Ycolor','y')
 set(gca,'Zcolor','y')
 set(gca,'color','k')

 set(gca,'YMinorGrid','off')

% neural net architecture plot, left side
% for interpolation, force neg weights to be red, pos to be green, low to be
% zero
 tmpcmp=[1:-.01:0]';
 tmpcmp2=[.01:.01:1]';
 cmp=[tmpcmp,zeros(size(tmpcmp)),zeros(size(tmpcmp))];
 cmp=[cmp;zeros(size(tmpcmp2)),tmpcmp2,zeros(size(tmpcmp2))];
 
 % determine location within gbest of layer weights only
 indLW  = find(net.trainParam.keymap(:,1) == 2 & ...
              net.trainParam.keymap(:,2) ~= net.numLayers); % finds layer weight indices within gbest (hidden layer only)
 indIW  = find(net.trainParam.keymap(:,1) == 1); % might have a use for these later
 indBI  = find(net.trainParam.keymap(:,1) == 0);
 indOLW = find(net.trainParam.keymap(:,1) == 2 & ...
              net.trainParam.keymap(:,2) == net.numLayers);
 %maxwt = max(abs(gbest(indLW))); % max value of layer weights only, for color determination
 maxwt = max(abs(gbest([indLW;indIW]))); % doesn't include biases
 minwt = -maxwt; % min value to use for color calc
 
 wtstretch = minwt:(maxwt-minwt)/(length(cmp)-1):maxwt; % reference vector for color interp
 
 subplot('position',[.075,.22,.5,.715]);
 nncnt = 0;
 clear wtpos
 netarch = [];
 for qq=1:length(net.layers);
    netarch(1,qq) = net.layers{qq}.dimensions;
 end
 netarch = [length(Pd{1}(:,1)),netarch];
 
 netarchlen = length(netarch);
 for lyrcnt = 1:netarchlen
    for wtcnt = 1:netarch(lyrcnt)
       nncnt=nncnt+1;
       wtpos(nncnt,:)=[lyrcnt,wtcnt-mean(1:netarch(lyrcnt))];

    end
 end
 for lyrcnt = 1:netarchlen-1
   tmpind1 = find(wtpos(:,1)==lyrcnt);
   tmpind2 = find(wtpos(:,1)==lyrcnt+1);
   for tmpcnt1 = 1:length(tmpind1)
      for tmpcnt2 = 1:length(tmpind2)
          
         if lyrcnt > 1
           wtval = net.LW{lyrcnt,lyrcnt-1}(tmpcnt2,tmpcnt1);
         else
           wtval = net.IW{1}(tmpcnt2,tmpcnt1);
         end
         % get color of each weight, scaled by min/max values of layer weights
         wtrgb = [interp1(wtstretch,cmp(:,1)',(wtval),'linear',1),...
                  interp1(wtstretch,cmp(:,2)',(wtval),'linear',1),...
                  interp1(wtstretch,cmp(:,3)',(wtval),'linear',0)];
         % default weight shape is a line
         wtshp = '-';
         
         % for wts = 0, plot a white dashed line, indicates broken connection
         if wtval==0
             wtshp='--';
             wtrgb=[1,1,1];
         end
         
         plot([wtpos(tmpind1(tmpcnt1),1),wtpos(tmpind2(tmpcnt2),1)],...
              [wtpos(tmpind1(tmpcnt1),2),wtpos(tmpind2(tmpcnt2),2)],...
              'color',wtrgb,'linestyle',wtshp);
         hold on
      end
   end
 end
 for dcnt = 1:nncnt
    lyrcnt=wtpos(dcnt,1);
    if lyrcnt==1 | lyrcnt==netarchlen
       netclr='w';
       netshp='>';
    else
       netclr='c';
       netshp='o';
    end
    plot(wtpos(dcnt,1),wtpos(dcnt,2),netshp,'markersize',10,...
          'color',netclr,'markerfacecolor','k','linewidth',2);
 end
 hold off
 title('Neural Net Architecture','color','m')
 set(gca,'color','k');
 xlab{1} = ['Gbestval = ',num2str(gbestval)];
 xlab{2} = [num2str(min(gbest([indIW]))),...
            ' <= Init Lyr Wts.. <= ',...
            num2str(max(gbest([indIW])))];
 if length(indLW)>0
     xlab{3} = [num2str(min(gbest([indLW]))),...
                ' <= Hid''n Lyr Wts. <= ',...
                num2str(max(gbest([indLW])))];
     tmpind=4;
 else
     tmpind=3;
 end
 xlab{tmpind} = [num2str(min(gbest([indOLW]))),...
            ' <= Output Lyr Wts. <= ',...
            num2str(max(gbest([indOLW])))];        
 xlab{tmpind+1} = [num2str(min(gbest([indBI]))),...
            ' <= Biases <= ',...
            num2str(max(gbest([indBI])))];
 xlabel(xlab,'color','m');
 %axis equal
 
% text box in lower right
% doing it this way so I can format each line any way I want
subplot('position',[.62,.1,.29,.4]);
  clear titstr
  if trelea==0
       PSOtype  = 'Common PSO';
       xtraname = 'Inertia Weight : ';
       xtraval  = num2str(iwt(length(iwt)));
       
     elseif trelea==2 | trelea==1
       
       PSOtype  = (['Trelea Type ',num2str(trelea)]);
       xtraname = ' ';
       xtraval  = ' ';
       
     elseif trelea==3
       PSOtype  = (['Clerc Type 1"']);
       xtraname = '\chi value : ';
       xtraval  = num2str(chi);

  end
  if isnan(errgoal)
    errgoalstr='Unconstrained';
  else
    errgoalstr=num2str(errgoal);
  end
  if minmax==1
     minmaxstr = ['Maximize to : '];
  elseif minmax==0
     minmaxstr = ['Minimize to : '];
  else
     minmaxstr = ['Target   to : '];
  end
  
  if rstflg==1
     rststat1 = 'Environment Change';
     rststat2 = ' ';
  else
     rststat1 = ' ';
     rststat2 = ' ';
  end
  
  titstr={'PSO Model: '      ,PSOtype;...
          'Dimensions : '    ,num2str(D);...
          '# of particles : ',num2str(ps);...
          minmaxstr          ,errgoalstr;...
          'Function : '      ,strrep(functname,'_','\_');...
          xtraname           ,xtraval;...
          rststat1           ,rststat2};

  text(.1,1,[titstr{1,1},titstr{1,2}],'color','g','fontweight','bold');
  hold on
  text(0,.9,[titstr{2,1},titstr{2,2}],'color','m');
  text(0,.8,[titstr{3,1},titstr{3,2}],'color','m');
  text(0,.7,[titstr{4,1}],'color','w');
  text(.45,.7,[titstr{4,2}],'color','m');
  text(0,.6,[titstr{5,1},titstr{5,2}],'color','m');
  text(0,.5,[titstr{6,1},titstr{6,2}],'color','w','fontweight','bold');
  text(0,.4,[titstr{7,1},titstr{7,2}],'color','r','fontweight','bold');

  hiddlyrstr = [];  
  for lyrcnt=1:length(net.layers)
     TF{lyrcnt} = net.layers{lyrcnt}.transferFcn;
     Sn(lyrcnt) = net.layers{lyrcnt}.dimensions;
     hiddlyrstr = [hiddlyrstr,', ',TF{lyrcnt}];
  end
  hiddlyrstr = hiddlyrstr(3:end);
  
  text(0,.35,['#neur/lyr = [ ',num2str(net.inputs{1}.size),'  ',...
       num2str(Sn),' ]'],'color','c','fontweight','normal',...
      'fontsize',10);   
  text(0,.275,['Lyr Fcn: ',hiddlyrstr],...
      'color','c','fontweight','normal','fontsize',9);

  legstr = {'Brighter Green = More Positive Wt.';...
            'Brighter Red = More Negative Wt.';...
            'Dashed White = zero Wt., no connect'};

  text(0,0.025,legstr{1},'color','g','fontsize',9);
  text(0,-.05,legstr{2},'color','r','fontsize',9);
  text(0,-.126,legstr{3},'color','w','fontsize',9);

  hold off

  set(gca,'color','k');
  set(gca,'visible','off');

  drawnow