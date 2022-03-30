import React from "react";
import { useQuery, UseQueryArgs, UseQueryResponse } from "urql";

/**
 * Urql only supports "merge/infinite" pagination by adoptinh the GraphCache (a global normalized cache),
 * which certainly is an overkill for this demo.
 *
 * This hook wraps `useQuery` from urql and adds a light-weight merge previous and current result API.
 */
export function usePaginatedQuery<Data = any, Variables = object>(
  args: UseQueryArgs<Variables, Data> & {
    /**
     * Merge the old result with the new result.
     */
    mergeResult: (oldData: Data, newData: Data) => Data;
  }
): UseQueryResponse<Data, Variables> {
  const [query, queryFn] = useQuery(args);

  const { data, ...rest } = query;

  const mergeRef = React.useRef({ current: data, last: data });

  if (
    data &&
    mergeRef.current.current &&
    query.data !== mergeRef.current.last
  ) {
    mergeRef.current.current = args.mergeResult(mergeRef.current.current, data);
  }

  if (data != null && mergeRef.current.current == null) {
    mergeRef.current.current = data;
  }

  mergeRef.current.last = query.data;

  return [
    {
      ...rest,
      data: mergeRef.current.current,
    },
    queryFn,
  ];
}
