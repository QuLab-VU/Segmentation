function figure_handle=showmaxfigure(figure_nr)
%show figure maximized and with no annoying borders
figure_handle=figure(figure_nr);
set(figure_handle,'PaperPositionMode','auto');
subplot('Position', [0 0 1 1]);