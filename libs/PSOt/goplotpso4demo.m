% goplotpso4demo.m
% simple graphing prog for use with PSO demo script

% Brian Birge
% Rev 1.0
% 1/1/3

% setup figure
clf
set(gcf,'Position',[651    31   626   474]); % this is computer dependent
%set(gcf,'Position',[743    33   853   492]); % this is computer dependent
set(gcf,'Doublebuffer','on');

% the very first time this routine is called it will do all this, the rest of
% the time it will be faster, just sets up the error topology (function shape)
% so we can see what the particles are surfing on top of
%if ~exist('f6val')
%   aviobj=avifile('demopsobehavior.avi','fps',30,'compression','Cinepak',...
%                  'Quality',100);
%end
if ~exist('f6val') | rstflg == 1
   numptsx = 300; % # of pts in each axis to plot
   numptsy = 250;
   
   x=[VR(1,1):(VR(1,2)-VR(1,1))/(numptsx-1):VR(1,2)];
   y=[VR(2,1):(VR(2,2)-VR(2,1))/(numptsy-1):VR(2,2)];
   ptsx=length(x);
   ptsy=length(y);
   cntpts=0;
   xy=zeros(ptsx*ptsy,2); % preallocate
   for ii=1:ptsx
     for jj=1:ptsy      
        cntpts=cntpts+1;
        xy(cntpts,1:2)=[x(ii),y(jj)]; 
     end
   end
   f6val = eval([functname,'([xy]);']);
   f6val = reshape(f6val,ptsy,ptsx);
end
 
% function surface plot, left side
 subplot('position',[0.1,0.1,.5,.825]);
 set(gcf,'color','k')
 surf(x,y,f6val)
 cmp=copper;
 colormap(cmp);
 
 if minmax==0 % minimize
    view(45,-45)
 elseif minmax==1 % maximize
    view(-45,45)
 else % to target
    view(3)
 end
 
 shading interp
 xlabel('input1','color','y')
 ylabel('input2','color','y')
 zlabel('output','color','y')
 
 hold on     
 plot3(pos(:,1),pos(:,2),out,'b.','Markersize',7)
 plot3(pbest(:,1),pbest(:,2),pbestval,'g.','Markersize',7);
 plot3(gbest(1),gbest(2),gbestval,'r.','Markersize',25);
 hold off
 
 titstr1=sprintf(['%11.6g = %s( [ %9.6g, %9.6g ] )'],...
                gbestval,strrep(functname,'_','\_'),gbest(1),gbest(2));
 title(titstr1,'color','w','fontweight','bold');
 
 set(gca,'Xcolor','y')
 set(gca,'Ycolor','y')
 set(gca,'Zcolor','y')
 set(gca,'color','k')
 
 %axis tight
 
% error plot, upper right
subplot('position',[.7,.6,.27,.32]);
 semilogy(tr(find(~isnan(tr))),'color','m','linewidth',2)
 %plot(tr(find(~isnan(tr))),'color','m','linewidth',2)
 xlabel('epoch','color','y')
 ylabel('gbest val.','color','y')
 title('Gbest vs. Iterations','color','m','fontweight','bold')
 grid on
 axis tight

 set(gca,'Xcolor','y')
 set(gca,'Ycolor','y')
 set(gca,'Zcolor','y')
 set(gca,'color','k')

 set(gca,'YMinorGrid','off')
 
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
  
  titstr={PSOtype            ,' ';...
          'Dimensions : '    ,num2str(D);...
          '# of particles : ',num2str(ps);...
          minmaxstr          ,errgoalstr;...
          'Function : '      ,strrep(functname,'_','\_');...
          xtraname           ,xtraval;...
          rststat1           ,rststat2};
  
  text(.1,.9,[titstr{1,1},titstr{1,2}],'color','g','fontweight','bold');
  hold on
  text(.1,.8,[titstr{2,1},titstr{2,2}],'color','m');
  text(.1,.7,[titstr{3,1},titstr{3,2}],'color','m');
  text(.1,.6,[titstr{4,1}],'color','w');
  text(.55,.6,[titstr{4,2}],'color','m');
  text(.1,.5,[titstr{5,1},titstr{5,2}],'color','m');
  text(.1,.4,[titstr{6,1},titstr{6,2}],'color','w','fontweight','bold');
  text(.1,.3,[titstr{7,1},titstr{7,2}],'color','r','fontweight','bold');
  
  legstr = {'Red   = Global Best';...
            'Green = Personal Bests';...
            'Blue  = Current Positions'};
  text(.1,.1,legstr{1},'color','r');
  text(.1,0,legstr{2},'color','g');
  text(.1,-.1,legstr{3},'color','b');
  
  hold off

  set(gca,'color','k');
  set(gca,'visible','off');
  
  drawnow
  
%% this part copies the picture and sends it back to the workspace to be put into
%% a movie
% F      = getframe(gcf);
% aviobj = addframe(aviobj,F);
% 
 %if i==me
 %   close(aviobj);
 %end