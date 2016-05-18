function ppnd(p) {
    var a0 = 2.50662823884;
    var a1 = -18.61500062529;
    var a2 = 41.39119773534;
    var a3 = -25.44106049637;
    var b1 = -8.47351093090;
    var b2 = 23.08336743743;
    var b3 = -21.06224101826;
    var b4 = 3.13082909833;
    var c0 = -2.78718931138;
    var c1 = -2.29796479134;
    var c2 = 4.85014127135;
    var c3 = 2.32121276858;
    var d1 = 3.54388924762;
    var d2 = 1.63706781897;
    var r;
    var split = 0.42;
    var value;

    /*
       0.08 < P < 0.92
       */
    if ( Math.abs( p - 0.5 ) <= split )
    {
        r = ( p - 0.5 ) * ( p - 0.5 );

        value = ( p - 0.5 ) * ( ( (
                        a3   * r
                        + a2 ) * r
                    + a1 ) * r
                + a0 ) / ( ( ( (
                                b4   * r
                                + b3 ) * r
                            + b2 ) * r
                        + b1 ) * r
                    + 1.0 );
    }
    /*
       P < 0.08 or P > 0.92,
       R = min ( P, 1-P )
       */
    else if ( 0.0 < p && p < 1.0 ) {
        if ( 0.5 < p ) {
            r = Math.sqrt ( - Math.log ( 1.0 - p ) );
        } else {
            r = Math.sqrt ( - Math.log ( p ) );
        }

        value = ( ( (
                        c3   * r
                        + c2 ) * r
                    + c1 ) * r
                + c0 ) / ( (
                        d2   * r
                        + d1 ) * r
                    + 1.0 );

        if ( p < 0.5 )
        {
            value = - value;
        }
    }
    /*
       P <= 0.0 or 1.0 <= P
       */
    else {
        value = NaN;
    }

    return value;
}


