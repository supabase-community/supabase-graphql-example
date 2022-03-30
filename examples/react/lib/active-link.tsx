import React from "react";
import { useRouter } from "next/router";
import Link from "next/link";

/**
 * @source https://nextjs.org/docs/api-reference/next/link
 * @source https://github.com/vercel/next.js/tree/canary/examples/active-class-name
 */
export function ActiveLink({
  children,
  activeClassName,
  ...props
}: {
  children: React.ReactNode;
  activeClassName: string;
  href: string;
  as?: string;
}) {
  const { asPath, isReady } = useRouter();

  const child = React.Children.only(children) as React.DetailedReactHTMLElement<
    any,
    HTMLElement
  >;
  const childClassName = child.props?.className || "";
  const [className, setClassName] = React.useState(childClassName);

  React.useEffect(() => {
    // Check if the router fields are updated client-side
    if (isReady) {
      // Dynamic route will be matched via props.as
      // Static route will be matched via props.href
      const linkPathname = new URL(props.as || props.href, location.href)
        .pathname;

      // Using URL().pathname to get rid of query and hash
      const activePathname = new URL(asPath, location.href).pathname;

      const newClassName =
        linkPathname === activePathname
          ? `${childClassName} ${activeClassName}`.trim()
          : childClassName;

      if (newClassName !== className) {
        setClassName(newClassName);
      }
    }
  }, [
    asPath,
    isReady,
    props.as,
    props.href,
    childClassName,
    activeClassName,
    setClassName,
    className,
  ]);

  return (
    <Link {...props}>
      {React.cloneElement(child, {
        className: className || null,
      })}
    </Link>
  );
}
