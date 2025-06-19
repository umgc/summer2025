'use client';
import { Button } from '@mui/material';
import { styled } from '@mui/material/styles';
import { useTheme, useMediaQuery } from "@mui/material";

const sizeMap = {
  small: {
    padding: '6px 12px',
    fontSize: '0.8rem',
    iconSize: '1.1rem',
    dimension: 36,
  },
  medium: {
    padding: '4px 14px',
    fontSize: '.75rem',
    iconSize: '.75rem',
    dimension: 44,
  },
  large: {
    padding: '8px 14px',
    fontSize: '1rem',
    iconSize: '0.9vw',
    dimension: 52,
  },
  xlarge2: {
    padding: '8px 16px',
    fontSize: '1vw',
    iconSize: '1.25vw',
    dimension: 60,
    iconDimension: "2.6vw",
  },
  xlarge: {
    padding: '12px 18px',
    fontSize: '2rem',
    iconSize: '1.5vw',
    dimension: 60,
  },
  iconXLarge: {
    iconSize: '2vw',
    iconDimension: "2.5vw",
  },
};

// Styled MUI Button
const AnimatedButton = styled(Button, {
  shouldForwardProp: (prop) =>
    prop !== 'mainColor' && prop !== 'reverse' && prop !== 'buttonSize' && prop !== 'iconOnly',
})(({ 
  mainColor, reverse, buttonSize, 
  borderradius, iconOnly, hovertextcolor, fullWidth,
  reversehovercolor, disabled, loading,
}) => {
  const { padding, fontSize, iconSize, iconDimension, dimension } = sizeMap[buttonSize] || sizeMap.medium;

  return {
    position: 'relative',
    loading: loading ? 'true' : 'false',
    loadingPosition: "end",
    zIndex: 0,
    overflow: 'hidden',
    textTransform: 'uppercase',
    border: disabled ? "3px solid gray" : '3px solid',
    borderColor: disabled ? "gray" : mainColor,
    color: disabled ? "white" : (reverse ? hovertextcolor : mainColor),
    padding: iconOnly ? 0 : padding,
    fontSize,
    fontWeight: 600,
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: iconOnly ? 0 : '0px',
    backgroundColor: disabled ? "gray" : (reverse ? mainColor : 'transparent'),
    borderRadius: iconOnly ? '50%' : borderradius,
    minWidth: iconOnly ? (iconDimension ? iconDimension : dimension) : 'auto',
    width: iconOnly ? 
      (iconDimension ? iconDimension : dimension) 
      : (fullWidth ? "100% ": 'auto'),
    height: iconOnly ? (iconDimension ? iconDimension : dimension) : 'auto',

    '& .MuiButton-startIcon': {
      marginRight: iconOnly ? 0 : '2px',
      '& svg': {
        fontSize: iconSize,
      },
    },
    '& .MuiButton-endIcon': {
      marginRight: iconOnly ? 0 : '2px',
      '& svg': {
        fontSize: iconSize,
      },
    },

    '& svg': {
      fontSize: iconSize,
    },

    '&::before': {
      content: '""',
      position: 'absolute',
      inset: 0,
      zIndex: -1,
      backgroundColor: disabled ? "gray" : mainColor,
      transform: reverse
        ? 'translate(0%, 0%) scale(2.5)'
        : 'translate(150%, 150%) scale(2.5)',
      borderRadius: '100%',
      transition: 'transform 0.5s ease',
    },

    '&:hover': {
      color: disabled ? "white" 
      : reverse 
        ? (reversehovercolor ? reversehovercolor : mainColor) : hovertextcolor,
      backgroundColor: 'transparent',
      transform: disabled ? "scale(1)" : 'scale(1.05)',
      '&::before': {
        transform:  disabled ? "" : reverse
          ? 'translate(150%, 150%) scale(2.5)'
          : 'translate(0%, 0%) scale(2.5)',
      },
    },

    '&:active': {
      transform: 'scale(0.95)',
    },
  };
});

// Unified Button Wrapper
export default function ButtonWrapper({
  text = 'Click Me',
  color = '#000000',
  reverse = false,
  spacing = 0,
  size = 'large',
  borderRadius = 0,
  startIcon = null,
  endIcon = null,
  iconOnly = false,
  hoverTextColor = '#ffffff',
  responsive = true,
  border = 'none',
  onclick = () => {},
  fullWidth = false,
  reverseHoverColor,
  disabled = false,
  loading = false,
}) {

  const theme = useTheme();

  // Breakpoint-specific logic
  const isXs = useMediaQuery(theme.breakpoints.only('xs'));
  const isSm = useMediaQuery(theme.breakpoints.only('sm'));
  const isMd = useMediaQuery(theme.breakpoints.only('md'));
  const isLg = useMediaQuery(theme.breakpoints.only('lg'));
  const isXl = useMediaQuery(theme.breakpoints.only('xl'));

  let responsiveSize = size;

  if (responsive) {
    if (isXs) responsiveSize = "small";
    else if (isSm) responsiveSize = "small";
    else if (isMd) responsiveSize = "medium";
    else if (isLg) responsiveSize = "large";
    else if (isXl) responsiveSize = size;
  }


  return (
    <AnimatedButton
      mainColor={color}
      reverse={reverse}
      buttonSize={responsiveSize}
      borderradius={borderRadius}
      iconOnly={iconOnly}
      startIcon={!iconOnly ? startIcon : undefined}
      endIcon={!iconOnly ? endIcon : undefined}
      hovertextcolor={hoverTextColor}
      sx={{ 
        mr: spacing,
        border: border,
      }}
      onClick={onclick}
      disableRipple
      disableFocusRipple
      fullWidth={fullWidth}
      reversehovercolor={reverseHoverColor}
      disabled={disabled}
      loading={loading}
      loadingPosition="end"
    >
      {iconOnly ? startIcon : <span>{text}</span>}
    </AnimatedButton>
  );
}
