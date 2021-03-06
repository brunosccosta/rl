close all;
clear all;
clc;

folder = '../results/mat/';

desired_performance = -1000;
times_in_row = 1;
max_episodes=300;
power_of_two=11;

Z=NaN(max_episodes, power_of_two);

for i=1:power_of_two
    load(strcat(folder, 'dyna-mlac', num2str(i), '.mat'));
    cr = cr;
    Z(1:size(cr,2),i) = mean(cr( (cr(:,end) > desired_performance), :));
end

% Prepare axes
[X,Y] = meshgrid(1:power_of_two, 1:max_episodes);

h=figure;
hold on;

%set(h,'units','normalized','outerposition',[0 0 1 1]);
%hAxes = axes('Parent',h,'Layer','top','FontSize',24);

h1=surf(X,Y,Z,'EdgeColor','none');
set(h1,'facecolor','interp');

h2=surf(X,Y,ones(max_episodes, power_of_two)*desired_performance,'FaceColor', 'green', 'EdgeColor','none');
set(h2,'facealpha',0.4);

xlabel('Updates per control step','FontSize',24);
ylabel('Episodes','FontSize',24);
zlabel('Rise Time','FontSize',24);

view(-25,30);

saveas( gcf, '3dsurf', 'png' );
hold off;

h2=figure;

hAxes = axes('Parent',h2,'Layer','top','FontSize',24);
contour3(X,Y,Z,20);
view(-90,90);

xlabel('Updates per control step','FontSize',24);
ylabel('Episodes','FontSize',24);
zlabel('Rise Time','FontSize',24);

colorbar;

saveas( gcf, 'contour1', 'png' );

view(-25,30);
saveas( gcf, 'contour2', 'png' );
hold off;