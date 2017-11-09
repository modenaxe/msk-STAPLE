   
   
   figure()

    trisurf(ProxTib,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none'); % 0.8,0.8,0.85

    hold on

    axis equal

    light('Position',CS.Origin' + 300*CS.Y + 200*CS.X,'Style','local')

    light('Position',CS.Origin' + 200*CS.Y - 200*CS.X,'Style','local')

    light('Position',CS.Origin' + 50*CS.Y + 50*CS.X - 500*CS.Z,'Style','local')

    plotDot( PtsMedThird, 'r', 1.25 )

    plotDot( PtMedialThirdOfTT, 'g', 2.5 )

    plotDot( PtsTT, 'b', 1.25 )

    hold on

    grid off

    lighting gouraud
