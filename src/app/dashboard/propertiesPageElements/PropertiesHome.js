import React, { useEffect } from 'react';
import withRoot from './withRoot';

import RealEstatePage from './MainPropertySection/MainSection';

function Index({appBarHeight = "10vw"}) {

  /*useEffect(() => {
    // Scroll to the top of the page when the component mounts
    window.scrollTo(0, 0);
  }, []);*/

  return (
    <React.Fragment>
      <RealEstatePage appBarHeight={appBarHeight}/>
    </React.Fragment>
  );
}

export default withRoot(Index);
